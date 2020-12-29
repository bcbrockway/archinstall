#!/bin/bash

set -e

source common.sh
.env --file install.env export

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

echo "Installing packages"

yays "${XORG_PKGS[@]}"

if [[ "$VIDEO" == vmware ]]; then
  sudo systemctl enable vboxservice
  sudo usermod -G vboxsf -a "$USERNAME"
fi

echo "Copying xorg config files"

sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
sudo cp etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf

echo "Configuring lightdm"
if ! grep autologin /etc/group > /dev/null 2>&1; then
  echo "Adding autologin group"
  sudo groupadd -r autologin
fi
if ! grep autologin /etc/group | grep $USERNAME > /dev/null 2>&1; then
  sudo gpasswd -a $USERNAME autologin
fi
sudo sed -i "s/#*\(autologin-user\)=.*/\1=$USERNAME/g" /etc/lightdm/lightdm.conf
