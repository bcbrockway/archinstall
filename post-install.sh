#!/bin/bash

set -e

FULL_NAME="Bobby Brockway"
EMAIL_ADDRESS="bbrockway@mintel.com"

USERNAME="bbrockway"
HIDPI="true"
TERMINAL_FONT="ter-v32n"
KEYMAP="uk"

function aur-get {
  local package; package=$1

  if ! pacman -Qi "$package" > /dev/null 2>&1; then
    echo "Installing package: $package"
    sudo -u $USERNAME yay -S -a --answerdiff N --answerclean A --noconfirm "$package"
  else
    echo "Package $package is already installed. Skipping..."
  fi
}

function key-value {
  local key; key=$1
  local value; value=$2
  local filename; filename=$3

  if grep -P "^$key=" $filename > /dev/null; then
    sed --in-place "s/^$key=.*/$key=$value/" $filename
  else
    echo "$key=$value" >> $filename
  fi
}

echo "Checking for username: $USERNAME"
if ! grep ${USERNAME} /etc/passwd > /dev/null; then
  echo "Setting up ${USERNAME}"
  useradd -G wheel -m ${USERNAME}
fi

echo "Checking sudo permissions"
if grep -P '^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)' /etc/sudoers; then
  echo "Giving wheel group sudo permissions"
  sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
fi

echo "Checking console settings"
key-value FONT $TERMINAL_FONT /etc/vconsole.conf
key-value KEYMAP $KEYMAP /etc/vconsole.conf
echo "Contents of /etc/vconsole.conf:"
cat /etc/vconsole.conf

echo "Installing packages"
pacman -Sy --needed --noconfirm --quiet \
  bluez \
  blueman \
  dmenu \
  git \
  go \
  i3-wm \
  i3lock \
  i3status \
  networkmanager \
  python \
  stow \
  terminator \
  vim \
  xorg

if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
  pacman -S --needed --noconfirm base-devel
  YAYDIR=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "${YAYDIR}"
  chmod 777 "$YAYDIR"
  pushd "$YAYDIR"
  sudo -u $USERNAME makepkg -si --noconfirm
  popd
fi

echo "Setting up git"
if ! sudo -u $USERNAME git config --global user.name; then
  sudo -u $USERNAME git config --global user.name "$FULL_NAME"
fi
if ! sudo -u $USERNAME git config --global user.email; then
  sudo -u $USERNAME git config --global user.email "$EMAIL_ADDRESS"
fi

aur-get google-chrome
aur-get insync
aur-get oh-my-zsh-git
aur-get vim-plug
