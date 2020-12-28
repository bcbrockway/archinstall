#!/bin/bash

set -ex

export XORG_PKGS=(
  lightdm
  noto-fonts
  noto-fonts-emoji
  ttf-dejavu
  xdg-utils
  xf86-input-libinput
  xorg-server
  xorg-xinit
  xorg-xrandr
  xorg-xrdb
)

source common.sh

case "$VIDEO" in
  nvidia)
    XORG_PKGS+=(nvidia)
    ;;
  intel)
    XORG_PKGS+=(xf86-video-intel)
    ;;
  vmware)
    XORG_PKGS+=(virtualbox-guest-utils xf86-video-vmware)
    ;;
  *)
    panic "Only nvidia, intel and vmware supported"
esac

yays "${XORG_PKGS[@]}"

if [[ "$VIDEO" == vmware ]]; then
  sudo systemctl enable vboxservice
  sudo usermod -G vboxsf -a "$USERNAME"
fi

# Configure xorg
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
sudo cp etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
