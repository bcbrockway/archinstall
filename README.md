## Usage

### Local Steps

Do the following locally on the machine itself:

1. Set up the network
1. Run passwd
1. Check that PermitRootLogin yes is present (and uncommented) in /etc/ssh/sshd_config
1. Start sshd

### SSH Steps

Get a UK-only mirrorlist for pacman:

```bash
loadkeys uk
timedatectl set-ntp true
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
wget https://www.archlinux.org/mirrorlist/\?country\=GB\&protocol\=http\&protocol\=https\&ip_version\=4\&use_mirror_status\=on -O /etc/pacman.d/mirrorlist
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

pacman -Sy git --noconfirm
git clone git@github.com:bcbrockway/archinstall.git
```