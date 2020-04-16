#!/bin/bash

set -e

source common.sh
.env --file install.env export

# Add multithreading support to makepkg
sudo cp etc/makepkg.conf /etc/makepkg.conf

# Install yay
if ! command yay > /dev/null 2>&1; then
  echo "Installing yay"
  yaydir=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "$yaydir"
  pushd "$yaydir"
  makepkg -si --noconfirm
  popd
fi

yays \
  lightdm-slick-greeter \
  snapd

# LightDM Slick Greeter
sudo cp etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm

# Git config
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL_ADDRESS"
git config --global core.excludesfile ~/.gitignore-global

# Snapd
if ! systemctl is-active --quiet snapd.socket; then
  sudo systemctl enable --now snapd.socket
fi
if [[ ! -h /snap ]]; then
  sudo ln -s /var/lib/snapd/snap /snap
fi

echo "Reboot? [Y/n]: "
read -r reboot
if [[ ! "$reboot" =~ [Nn] ]]; then
  reboot
fi
