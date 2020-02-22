#!/bin/bash

set -ex

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$THISDIR"

source common.sh

## Set the keyboard layout
loadkeys "$KEYMAP"

## Verify the boot mode
if [[ ! -d /sys/firmware/efi ]]; then
  panic "Must boot in EFI mode!"
fi

## Update the system clock
timedatectl set-ntp true

## Partition the disks
cat /proc/partitions
echo "Which drive would you like to partition?"
read -r HDD
gdisk "/dev/$HDD"

cat /proc/partitions
echo "Which is your root partition? (e.g. sda2): "
read -r ROOT_PARTITION
if [[ -e "/dev/$ROOT_PARTITION" ]]; then
  ROOT_PARTITION="/dev/$ROOT_PARTITION"
else
  panic "/dev/$ROOT_PARTITION doesn't exist"
fi

echo "Which is your boot partition? (e.g. sda1): "
read -r BOOT_PARTITION
if [[ -e "/dev/$BOOT_PARTITION" ]]; then
  BOOT_PARTITION="/dev/$BOOT_PARTITION"
else
  panic "/dev/$BOOT_PARTITION doesn't exist"
fi

## Encrypt the root partition
echo "Do you want to encrypt the root partition? [Y/n]: "
read -r ENCRYPT_ROOT
if [[ ! "$ENCRYPT_ROOT" =~ [Nn] ]]; then
  cryptsetup -y -v luksFormat "$ROOT_PARTITION"
  cryptsetup open "$ROOT_PARTITION" cryptroot
fi

## Format the partitions
echo "Format root partition? [y/N]: "
read -r -n1 FORMAT_ROOT
if [[ "$FORMAT_ROOT" =~ [Yy] ]]; then
  if [[ ! "$ENCRYPT_ROOT" =~ [Nn] ]]; then
    mkfs.ext4 /dev/mapper/cryptroot
  else
    mkfs.ext4 "$ROOT_PARTITION"
  fi
fi
echo "Format boot partition? [y/N]: "
read -r -n1 FORMAT_BOOT
if [[ "$FORMAT_BOOT" =~ [Yy] ]]; then
  mkfs.fat "$BOOT_PARTITION"
fi

## Mount the file systems
if [[ ! "$ENCRYPT_ROOT" =~ [Nn] ]]; then
  mount /dev/mapper/cryptroot "$ARCH"
else
  mount "$ROOT_PARTITION"
fi
mkdir "$ARCH/boot"
mount "$BOOT_PARTITION" "$ARCH/boot"

## Install essential packages
pacstrap "$ARCH" base base-devel linux linux-firmware networkmanager git vim intel-ucode

## Configure the system

# Fstab
genfstab -U "$ARCH" >> "$ARCH/etc/fstab"

# Time zone
arch-chroot "$ARCH" ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
arch-chroot "$ARCH" hwclock --systohc

# Localisation
sed -i 's/^#\('"$LOCALE"'.*\)/\1/' "$ARCH/etc/locale.gen"
arch-chroot "$ARCH" locale-gen
key_value LANG "$LOCALE" "$ARCH/etc/locale.conf"
key_value KEYMAP "$KEYMAP" "$ARCH/etc/vconsole.conf"
EOF

# Network Configuration
echo "$HOSTNAME" > "$ARCH/etc/hostname"
cat <<EOF > "$ARCH/etc/hosts"
127.0.0.1  localhost
::1        localhost
127.0.1.1  $HOSTNAME.localdomain  $HOSTNAME
EOF

# Initramfs
if [[ ! "$ENCRYPT_ROOT" =~ [Nn] ]]; then
  sed -i 's/HOOKS=.*/HOOKS="base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck"/' "$ARCH"/etc/mkinitcpio.conf
  arch-chroot "$ARCH" mkinitcpio -P
fi

# Root password
arch-chroot "$ARCH" passwd

# Boot loader
arch-chroot "$ARCH" bootctl install
cp /usr/share/systemd/bootctl/loader.conf "$ARCH/boot/loader/"
echo "timeout 4" >> "$ARCH/boot/loader/loader.conf"
echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img" > "$ARCH/boot/loader/entries/arch.conf"
echo -e "options cryptdevice=UUID=$(blkid -s UUID -o value "$ROOT_PARTITION"):cryptroot resume=/dev/mapper/cryptroot root=/dev/mapper/cryptroot rw quiet" > "$ARCH/boot/loader/entries/arch.conf"
