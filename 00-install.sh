#!/bin/bash

set -e

source common.sh
.env --file 00-install.env export

if [[ "$HIDPI" == true ]]; then
  echo "Setting console font for HiDPI"
  pacman -Sy terminus-font
  setfont ter-v32n
  key_value FONT "ter-v32n" "$ARCH/etc/vconsole.conf"
fi

## Set the keyboard layout
echo "Setting keyboard layout"
loadkeys "$KEYMAP"

## Verify the boot mode
echo "Checking for EFI"
if [[ ! -d /sys/firmware/efi ]]; then
  panic "Must boot in EFI mode!"
fi

## Update the system clock
echo "Enabling NTP"
timedatectl set-ntp true

## Partition the disks
if [[ "$PARTITIONING_COMPLETE" != true ]]; then
  echo "Would you like to partition the disks? [Y/n]: "
  read -r partition_disks
  if [[ ! "$partition_disks" =~ [Nn] ]]; then
    cat /proc/partitions
    echo "Which drive would you like to partition?"
    read -r partition_hdd
    gdisk "/dev/$partition_hdd"
  fi

  cat /proc/partitions

  echo "Which is your boot partition? (e.g. sda1): "
  read -r boot_partition
  if [[ -e "/dev/$boot_partition" ]]; then
    boot_partition="/dev/$boot_partition"
    .env set boot_partition="/dev/$boot_partition"
  else
    panic "/dev/$boot_partition doesn't exist"
  fi

  echo "Which is your root partition? (e.g. sda2): "
  read -r root_partition
  if [[ -e "/dev/$root_partition" ]]; then
    root_partition="/dev/$root_partition"
  else
    panic "/dev/$root_partition doesn't exist"
  fi
fi

.env set boot_partition="$boot_partition"
.env set root_partition="$root_partition"
.env set PARTITIONING_COMPLETE=true

## Encrypt the root partition
if [[ "$ENCRYPTION_COMPLETE" != true ]]; then
  echo "Do you want to encrypt the root partition? [Y/n]: "
  read -r encrypt_root
  if [[ ! "$encrypt_root" =~ [Nn] ]]; then
    cryptsetup -y -v luksFormat "$root_partition"
    cryptsetup open "$root_partition" cryptroot
    encrypted=true
  else
    encrypted=false
  fi
fi

.env set encrypted="$encrypted"
.env set ENCRYPTION_COMPLETE=true

## Format the partitions
if [[ "$FORMATTING_COMPLETE" != true ]]; then
  echo "Format root partition? [y/N]: "
  read -r format_root
  if [[ "$format_root" =~ [Yy] ]]; then
    if [[ "$encrypted" == true ]]; then
      mkfs.ext4 /dev/mapper/cryptroot
    else
      mkfs.ext4 "$root_partition"
    fi
  fi
  echo "Format boot partition? [y/N]: "
  read -r format_boot
  if [[ "$format_boot" =~ [Yy] ]]; then
    mkfs.fat "$boot_partition"
  fi
fi

.env set FORMATTING_COMPLETE=true

## Mount the file systems
if [[ "$MOUNTING_COMPLETE" != true ]]; then
  echo "Mounting file systems"
  if [[ "$encrypted" == true ]]; then
    mount /dev/mapper/cryptroot "$ARCH"
  else
    mount "$root_partition"
  fi
  mkdir "$ARCH/boot"
  mount "$boot_partition" "$ARCH/boot"
fi

.env set MOUNTING_COMPLETE=true

## Install essential packages
if [[ "$PACSTRAP_COMPLETE" != true ]]; then
  echo "Installing Arch Linux"
  pacstrap "$ARCH" base base-devel linux linux-firmware networkmanager git vim intel-ucode
fi

.env set PACSTRAP_COMPLETE=true

## Configure the system

# Fstab
if [[ "$GENFSTAB_COMPLETE" != true ]]; then
  echo "Generating fstab"
  genfstab -U "$ARCH" >> "$ARCH/etc/fstab"
fi

.env set GENFSTAB_COMPLETE=true

# Time zone
if [[ "$TIMEZONE_COMPLETE" != true ]]; then
  echo "Setting timezone"
  arch-chroot "$ARCH" ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
  arch-chroot "$ARCH" hwclock --systohc
fi

.env set TIMEZONE_COMPLETE=true

# Localisation
if [[ "$LOCALE_COMPLETE" != true ]]; then
  echo "Setting localisation"
  sed -i 's/^#\('"$LOCALE"'.*\)/\1/' "$ARCH/etc/locale.gen"
  arch-chroot "$ARCH" locale-gen
  key_value LANG "$LOCALE" "$ARCH/etc/locale.conf"
  key_value KEYMAP "$KEYMAP" "$ARCH/etc/vconsole.conf"
fi

.env set LOCALE_COMPLETE=true

# Network Configuration
if [[ "$NETWORK_COMPLETE" != true ]]; then
  echo "Setting up networking"
  echo "$HOSTNAME" > "$ARCH/etc/hostname"
  cat <<EOF > "$ARCH/etc/hosts"
127.0.0.1  localhost
::1        localhost
127.0.1.1  $HOSTNAME.localdomain  $HOSTNAME
EOF
fi

.env set NETWORK_COMPLETE=true

# Initramfs
if [[ "$INITRAMFS_COMPLETE" != true ]]; then
  if [[ "$encrypted" == true ]]; then
    echo "Running mkinitcpio"
    sed -i 's/HOOKS=.*/HOOKS="base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck"/' "$ARCH"/etc/mkinitcpio.conf
    arch-chroot "$ARCH" mkinitcpio -P
  fi
fi

.env set INITRAMFS_COMPLETE=true

# Root password
if [[ "$PASSWD_COMPLETE" != true ]]; then
  echo "Changing root password"
  arch-chroot "$ARCH" passwd
fi

.env set PASSWD_COMPLETE=true

# Boot loader
if [[ "$BOOTLOADER_COMPLETE" != true ]]; then
  echo "Installing boot loader"
  arch-chroot "$ARCH" bootctl install
  cp /usr/share/systemd/bootctl/loader.conf "$ARCH/boot/loader/"
  echo "timeout 4" >> "$ARCH/boot/loader/loader.conf"
  echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img" > "$ARCH/boot/loader/entries/arch.conf"
  if [[ "$encrypted" == true ]]; then
    echo "options cryptdevice=UUID=$(blkid -s UUID -o value "$root_partition"):cryptroot resume=/dev/mapper/cryptroot root=/dev/mapper/cryptroot rw quiet" >> "$ARCH/boot/loader/entries/arch.conf"
  else
    echo "options root=PARTUUID=$(blkid -s PARTUUID -o value "$root_partition") rw" >> "$ARCH/boot/loader/entries/arch.conf"
  fi
fi

.env set BOOTLOADER_COMPLETE=true
