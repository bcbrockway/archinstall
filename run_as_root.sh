#!/bin/bash

set -e

FULL_NAME="Bobby Brockway"
EMAIL_ADDRESS="bbrockway@mintel.com"

USERNAME="bbrockway"
TERMINAL_FONT="ter-v32n"
KEYMAP="uk"

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $THISDIR

function require_aur {
  local package; package=$1
  
  if ! pacman -Qi "$package" > /dev/null 2>&1; then
    echo "Installing package: $package"
    sudo -u $USERNAME yay -S -a --answerdiff N --answerclean A --noconfirm "$package"
  else
    echo "Package $package is already installed. Skipping..."
  fi
}

function key_value {
  local key; key=$1
  local value; value=$2
  local filename; filename=$3

  if grep -P "^$key=" $filename > /dev/null; then
    sed --in-place "s/^$key=.*/$key=$value/" $filename
  else
    echo "$key=$value" >> $filename
  fi
}

function copy {
  local src; src=$1
  local dst

  if [[ $src =~ ^(\.\.|~|/) ]]; then
    echo "src references file outside this context ($src)"
    return 10
  fi
  if [[ ! -e $src ]]; then
    echo "src file does not exist ($src)"
    return 11
  fi
  
  dst=/$src
  
  if [[ -e $dst ]]; then
    if ! diff $dst $src; then
      echo "File $dst exists and is different. What would you like to do?"
      echo -n "[r]eplace [s]kip (default) [a]bort: "
      read -n 1 ans
      if [[ $ans == "r" ]]; then
        cp -r $src $dst
      elif [[ $ans == "s" ]] || [[ -z $ans ]]; then
        return 0
      elif [[ $ans == "a" ]]; then
        exit 1
      fi
    fi
  else
    cp -r $src $dst
  fi
}

########
# User #
########
echo "Checking for username: $USERNAME"
if ! grep ${USERNAME} /etc/passwd > /dev/null; then
  echo "Setting up ${USERNAME}"
  useradd -G wheel,video -m ${USERNAME}
fi

###########
# Sudoers #
###########
echo "Checking sudo permissions"
if grep -P '^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)' /etc/sudoers; then
  echo "Giving wheel group sudo permissions"
  sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
fi

###########
# Console #
###########
echo "Checking console settings"
key_value FONT $TERMINAL_FONT /etc/vconsole.conf
key_value KEYMAP $KEYMAP /etc/vconsole.conf
echo "Contents of /etc/vconsole.conf:"
cat /etc/vconsole.conf

#################
# Core Packages #
#################

echo "Installing packages"
pacman -Sy --needed --noconfirm --quiet \
  base-devel \
  bluez \
  blueman \
  curl \
  dmenu \
  git \
  go \
  i3-wm \
  i3lock \
  i3status \
  kubectl \
  light \
  man \
  mesa \
  mlocate \
  networkmanager \
  python \
  stow \
  terminator \
  tree \
  ttf-dejavu \
  udiskie \
  unzip \
  vim \
  virtualbox \
  wget \
  xf86-input-libinput \
  xf86-video-intel \
  xf86-video-nouveau \
  xorg-server \
  xorg-xrandr \
  xorg-xrdb \
  zsh

################
# AUR Packages #
################

su -l $USERNAME <<'EOF'
if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
  YAYDIR=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "${YAYDIR}"
  pushd "$YAYDIR"
  makepkg -si --noconfirm
  popd
fi
EOF

require_aur breeze-adapta-cursor-theme-git
require_aur google-chrome
require_aur google-cloud-sdk
require_aur insync
require_aur vim-plug

#####################
# Hardware Settings #
#####################

copy etc/udev/rules.d/backlight.rules
copy etc/X11/xorg.conf.d/00-keyboard.conf
copy etc/X11/xorg.conf.d/30-touchpad.conf

#######
# Git #
#######

su -l $USERNAME <<'EOF'
if ! git config --global user.name > /dev/null; then
  echo "Setting git user name"
  git config --global user.name "$FULL_NAME"
fi
if ! git config --global user.email > /dev/null; then
  echo "Setting git user email"
  git config --global user.email "$EMAIL_ADDRESS"
fi
EOF

#############
# Oh My Zsh #
#############
su -l $USERNAME <<'EOF'
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  OMZDIR=$(mktemp)
  pushd $OMZDIR
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  sh install.sh
  popd
fi
if [[ $SHELL != /bin/zsh ]]; then
  chsh -s /bin/zsh
fi
EOF

###########
# Cursors #
###########
copy usr/share/icons/default/index.theme

