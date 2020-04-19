#!/bin/bash

set -e

source common.sh
.env --file install.env export

# Add multithreading support to makepkg
sudo cp etc/makepkg.conf /etc/makepkg.conf

# Install yay
if ! command -v yay > /dev/null 2>&1; then
  echo "Installing yay"
  yaydir=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "$yaydir"
  pushd "$yaydir"
  makepkg -si --noconfirm
  popd
fi

yays \
  breeze-adapta-cursor-theme-git \
  firefox \
  i3lock-fancy-git \
  lightdm-slick-greeter \
  rxvt-unicode-wcwidthcallback \
  snapd \
  vim-plug \
  yadm

# Cursors
sudo cp usr/share/icons/default/index.theme /usr/share/icons/default/index.theme

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

# Oh My Zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Update dotfiles? [Y/n]: "
read -r update_dotfiles
if [[ ! "$update_dotfiles" =~ [Nn] ]]; then
  yadm clone https://github.com/bcbrockway/dotfiles.git
  yadm reset --hard origin/master
fi

if [[ ! $SHELL =~ .*/zsh ]]; then
  chsh -s /bin/zsh
fi
