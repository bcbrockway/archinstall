#!/bin/bash

set -e

source common.sh
.env --file install.env export

# Add multithreading support to makepkg
sudo cp etc/makepkg.conf /etc/makepkg.conf

# Install yay
if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
  yaydir=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "$yaydir"
  chmod 777 "$yaydir"
  pushd "$yaydir"
  makepkg -si --noconfirm
  popd
fi

yays \
  breeze-adapta-cursor-theme-git \
  i3lock-fancy-git \
  insync \
  snapd \
  vim-plug

#yays yq-bin

# Cursors
sudo cp usr/share/icons/default/index.theme /usr/share/icons/default/index.theme
