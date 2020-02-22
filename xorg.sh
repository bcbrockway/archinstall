#!/bin/bash

set -ex

source common.sh

xorg_pkgs=(
  xf86-input-libinput
  xorg-server
  xorg-xrandr
  xorg-xrdb
)

case "$VIDEO" in
  nvidia)
    xorg_pkgs+=(nvidia)
    ;;
  intel)
    xorg_pkgs+=(xf86-video-intel)
    ;;
  vmware)
    xorg_pkgs+=(virtualbox-guest-utils xf86-video-vmware virtualbox-guest-modules-arch)
    ;;
  *)
    panic "Only nvidia, intel and vmware supported"
esac

arch-chroot "$ARCH" pacmans "${xorg_pkgs[@]}"

if [[ "$VIDEO" == vmware ]]; then
  arch-chroot "$ARCH" systemctl enable vboxservice
  arch-chroot "$ARCH" usermod -G vboxsf -a "$USERNAME"
fi

# Configure xorg
copy etc/X11/xorg.conf.d/00-keyboard.conf
copy etc/X11/xorg.conf.d/30-touchpad.conf
