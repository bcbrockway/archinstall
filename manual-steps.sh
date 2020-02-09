## Check to ensure you have booted in EFI mode
ls /sys/firmware/efi

## Connect to WiFi
ip link set wlp58s0 up
wpa_supplicant -B -i wlp58s0 -c <(wpa_passphrase XXXXX XXXXX)
dhcpcd wlp58s0

## Update /etc/pacman.d/mirrorlist

## Get larger screen font
pacman -Sy terminus-font
setfont ter-v32n

## Enable SSH
pacman -S openssh
systemctl start sshd
passwd

## Partition everything with gdisk
cat /proc/partitions
gdisk /dev/nvme0n1

## Set up disk encryption
cryptsetup -y -v luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot  # <-- EFI partition created by Windows

## Install Arch
pacstrap /mnt git
arch-chroot /mnt

## Get this repo and run console.sh
git clone https://github.com/bcbrockway/archinstall.git
cd /archinstall
./console.sh

## Configure the bootloader
bootctl install
cd /boot/loader
cat <<EOF > loader.conf
default arch
timeout 4
EOF
cd entries
cat <<EOF > arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID_OF_nvme0n1p2>:cryptroot resume=/dev/mapper/cryptroot root=/dev/mapper/cryptroot rw quiet
EOF
## Get the UUID with :r !blkid
exit
reboot

## Configure HiDPI display
cat <<EOF >/home/${NEWUSER}/.Xresources
Xft.dpi: 192
Xft.autohint: 0
Xft.lcdfilter:  lcddefault
Xft.hintstyle:  hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
EOF
