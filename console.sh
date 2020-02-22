#!/bin/bash

# Install yay
if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
  yaydir=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "$yaydir"
  chmod 777 "$yaydir"
  pushd "$yaydir"
  sudo -u "$USERNAME" makepkg -si --noconfirm
  popd
fi

# Add multithreading support to makepkg
copy etc/makepkg.conf

# Install lightdm
pacman -S --needed --noconfirm --quiet lightdm
require_aur lightdm-slick-greeter
copy etc/lightdm/lightdm.conf
systemctl enable lightdm

# TODO: Install graphics drivers

# Install i3
echo "Installing packages"
pacman -Sy --needed --noconfirm --quiet \
  base-devel \
  dmenu \
  feh \
  fwupd \
  i3-wm \
  i3status \
  libnotify \
  light \
  man \
  mlocate \
  network-manager-applet \
  pasystray \
  pbzip2 \
  pigz \
  python \
  openssh \
  rsync \
  terminator \
  tree \
  ttf-dejavu \
  udiskie \
  unzip \
  vim \
  wget \
  xz \
  zsh \
  zstd
