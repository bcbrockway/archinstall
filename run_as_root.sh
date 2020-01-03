#!/bin/bash

set -e

FULL_NAME="Bobby Brockway"
EMAIL_ADDRESS="bbrockway@mintel.com"

USERNAME="bbrockway"
HIDPI="true"
TERMINAL_FONT="ter-v32n"
KEYMAP="uk"

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
key-value FONT $TERMINAL_FONT /etc/vconsole.conf
key-value KEYMAP $KEYMAP /etc/vconsole.conf
echo "Contents of /etc/vconsole.conf:"
cat /etc/vconsole.conf

#############
# Backlight #
#############
# Access to video group already provided in useradd
pacman -Sy --needed --noconfirm --quiet light
cat <<EOF >/etc/udev/rules.d/backlight.rules
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

#####################
# Required Packages #
#####################
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
  networkmanager \
  python \
  stow \
  terminator \
  ttf-dejavu \
  unzip \
  vim \
  wget \
  xorg

