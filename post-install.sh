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
  lightdm-slick-greeter \
  snapd \
  vim-plug

#yays yq-bin

# Cursors
sudo cp usr/share/icons/default/index.theme /usr/share/icons/default/index.theme

# LightDM Slick Greeter
sudo cp etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm

# Git config
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL_ADDRESS"
git config --global core.excludesfile ~/.gitignore-global

# Oh My Zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [[ $SHELL != /bin/zsh ]]; then
  chsh -s /bin/zsh
fi

# Snapd
if ! systemctl is-active --quiet snapd.socket; then
  systemctl enable --now snapd.socket
fi
if [[ ! -h /snap ]]; then
  ln -s /var/lib/snapd/snap /snap
  echo "Snap needs to reboot your system. Ok? [y/n]: "
  read -n1 ans
  if [[ $ans =~ [Yy] ]]; then
    reboot
  else
    touch /tmp/REBOOT_REQUIRED
  fi
fi
if [[ ! -f /tmp/REBOOT_REQUIRED ]]; then
  snap_install goland --classic
  snap_install pycharm-community --classic
fi

echo "Install work packages? [Y/n]: "
read -r install_work