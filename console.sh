#!/bin/bash

set -e

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$THISDIR"

source common.sh

# Initial packages
pacman -Sy --needed --noconfirm --quiet \
  linux-firmware \
  networkmanager \
  sudo \
  terminus-font \
  vim

# Set up console
echo "Checking console settings"
key_value FONT "$TERMINAL_FONT" /etc/vconsole.conf
key_value KEYMAP "$KEYMAP" /etc/vconsole.conf
echo "Contents of /etc/vconsole.conf:"
cat /etc/vconsole.conf

# Configure hardware
echo "Checking hardware config"
copy etc/udev/rules.d/backlight.rules
copy etc/X11/xorg.conf.d/00-keyboard.conf
copy etc/X11/xorg.conf.d/30-touchpad.conf

# Set up user
echo "Checking for username: $USERNAME"
if ! grep "$USERNAME" /etc/passwd > /dev/null; then
  echo "Setting up $USERNAME"
  useradd -G wheel,video -m "$USERNAME"
fi

# Set up sudoers
pacman -Sy --needed --noconfirm --quiet sudo
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

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
  xf86-input-libinput \
  xorg-server \
  xorg-xrandr \
  xorg-xrdb \
  xz \
  zsh \
  zstd