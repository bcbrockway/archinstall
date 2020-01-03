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

if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
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

aur-get vim-plug
aur-get oh-my-zsh-git
if [[ $SHELL != /bin/zsh ]]; then
  chsh -s /bin/zsh
fi

###########
# Cursors #
###########
aur-get breeze-adapta-cursor-theme-git
sudo cat <<EOF >/usr/share/icons/default/index.theme
[Icon Theme]
Inherits=Breeze-Adapta-Cursor
EOF

aur-get google-chrome
aur-get google-cloud-sdk
aur-get insync
