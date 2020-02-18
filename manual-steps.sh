## Check to ensure you have booted in EFI mode
ls /sys/firmware/efi

## Connect to WiFi
ip link set wlp58s0 up
wpa_supplicant -B -i wlp58s0 -c <(wpa_passphrase XXXXX XXXXX)
dhcpcd wlp58s0

## Update system time
timedatectl set-ntp true

## Update /etc/pacman.d/mirrorlist
vim /etc/pacman.d/mirrorlist

## Enable SSH
pacman -S openssh
systemctl start sshd
passwd

## Get larger screen font
pacman -Sy terminus-font
setfont ter-v32n

########################################################################################
## At this point you can ssh in from somewhere else which will help with copy/pasting ##
########################################################################################

## Partition everything with gdisk
cat /proc/partitions
gdisk /dev/nvme0n1

## Set up disk encryption
cryptsetup -y -v luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

## Install Arch
pacstrap /mnt base base-devel linux linux-firmware git vim

## Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Switch to new / dir
arch-chroot /mnt

# Set root password
passwd

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
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID_OF_nvme0n1p2>:cryptroot resume=/dev/mapper/cryptroot root=/dev/mapper/cryptroot rw quiet
EOF
## Get the UUID with :r !blkid
exit
reboot
