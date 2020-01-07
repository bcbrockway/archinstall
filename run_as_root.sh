#!/bin/bash

set -e

FULL_NAME="Bobby Brockway"
EMAIL_ADDRESS="bbrockway@mintel.com"

USERNAME="bbrockway"
TERMINAL_FONT="ter-v32n"
KEYMAP="uk"

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "$THISDIR"

function require_aur {
  local package; package=$1
  
  if ! pacman -Qi "$package" > /dev/null 2>&1; then
    echo "Installing package: $package"
    sudo -u $USERNAME yay -S -a --answerdiff N --answerclean A --noconfirm "$package"
  else
    echo "Package $package already installed. Skipping..."
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

function snap_install {
  local package; package=$1
  local opts; opts="${@:2}"

  if ! snap list $package >/dev/null; then
    snap install $package $opts
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
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

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
  arandr \
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
  git-crypt \
  kubectl \
  light \
  lightdm \
  man \
  mesa \
  mlocate \
  networkmanager \
  network-manager-applet \
  pasystray \
  pulseaudio \
  pulseaudio-bluetooth \
  python \
  python-toml \
  openssh \
  rsync \
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
  yubico-pam \
  zsh

systemctl enable lightdm --now
systemctl enable sshd --now
systemctl enable NetworkManager --now

################
# AUR Packages #
################

if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
  YAYDIR=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "${YAYDIR}"
  chmod 777 "$YAYDIR"
  pushd "$YAYDIR"
  sudo -u $USERNAME makepkg -si --noconfirm
  popd
fi

require_aur breeze-adapta-cursor-theme-git
require_aur google-chrome
require_aur google-cloud-sdk
require_aur i3lock-fancy-git
require_aur insync
require_aur lightdm-slick-greeter
require_aur python-pre-commit
require_aur snapd
require_aur vim-plug
require_aur zoom

#################
# Snap Packages #
#################
echo "Snap config"
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
fi

#####################
# Hardware Settings #
#####################
echo "Checking hardware config"
copy etc/udev/rules.d/backlight.rules
copy etc/X11/xorg.conf.d/00-keyboard.conf
copy etc/X11/xorg.conf.d/30-touchpad.conf

#######
# Git #
#######
echo "Checking git config"
sudo -u $USERNAME bash <<EOF
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL_ADDRESS"
git config --global core.excludesfile ~/.gitignore-global
EOF

#############
# Oh My Zsh #
#############
echo "Checking zsh config"
sudo -u $USERNAME bash <<'EOF'
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [[ $SHELL != /bin/zsh ]]; then
  chsh -s /bin/zsh
fi
EOF

###########
# Cursors #
###########
echo "Checking cursor config"
copy usr/share/icons/default/index.theme

###########
# lightdm #
###########
echo "Checking display manager config"
copy etc/lightdm/lightdm.conf

echo "Script complete"
