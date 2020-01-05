#!/bin/bash

set -e

HOSTNAME="arch-vm"
LOCALE="en_GB.UTF-8"
TIMEZONE="Europe/London"

echo "Setting timezone to ${TIMEZONE}"

ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

echo "Setting the hardware clock to the system time"

hwclock --systohc

echo "Setting localisation"

sed -i 's/#\('"${LOCALE}"'\)/\1/g' /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

echo "Setting hostname"

echo "${HOSTNAME}" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >> /etc/hosts

# NETWORK CONFIG HERE
pacman -Sy --needed --noconfirm openssh
systemctl enable sshd
sed -i 's/#\(PermitRootLogin\).*/\1 yes/' /etc/ssh/sshd_config

echo "Setting up boot manager"

pacman -S --needed --noconfirm grub intel-ucode
if [[ ! -d /boot/grub ]]; then
  grub-install --target=i386-pc /dev/sda
fi
grub-mkconfig -o /boot/grub/grub.cfg

passwd

# Undo this at the end:
# sed -i 's/#\(PermitRootLogin\).*/\1 yes/' /etc/ssh/sshd_config