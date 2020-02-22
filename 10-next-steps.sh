#!/bin/bash

set -ex

source common.sh
.env --file 10-next-steps.env export

# Configure backlight
echo "Configuring backlight"
copy etc/udev/rules.d/backlight.rules

# Install pikuar
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -fsri

# Install lightdm
pacman -S --needed --noconfirm --quiet lightdm
require_aur lightdm-slick-greeter
copy etc/lightdm/lightdm.conf
systemctl enable lightdm
