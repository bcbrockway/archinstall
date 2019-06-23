## Usage

### Local Steps

Do the following locally on the machine itself:

1. Set up the network
1. Run passwd
1. Check that PermitRootLogin yes is present (and uncommented) in /etc/ssh/sshd_config
1. Start sshd

### SSH Steps

```bash
# Configure UK keyboard
loadkeys uk
# Setup NTP
timedatectl set-ntp true
# Partition, format and mount the disk
(
echo n # add a new partition
echo p # primary partition
echo 1 # partition number
echo   # default start sector
echo   # default end sector
echo w # write and exit
) | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
# Get an up-to-date, UK-specific mirrorlist for pacman
wget https://www.archlinux.org/mirrorlist/\?country\=GB\&protocol\=http\&protocol\=https\&ip_version\=4\&use_mirror_status\=on -O /etc/pacman.d/mirrorlist
# Install Arch on the mount partition
pacstrap /mnt base
# Create an fstab file
genfstab -U /mnt >> /mnt/etc/fstab
# Make /mnt the root partition
arch-chroot /mnt
# Download git, clone this repo, and run the install script
pacman -Sy git --noconfirm
cd /tmp && git clone https://github.com/bcbrockway/archinstall.git
cd archinstall && ./init-vm.sh
```
