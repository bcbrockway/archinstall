#!/bin/bash

export I3_PKGS=(
  arandr
  blueman
  i3-gaps
  i3status
  dmenu
  feh
  network-manager-applet
  pasystray
  rxvt-unicode
  udiskie
)

arch-chroot "$ARCH" pacman -S --needed --noconfirm "${I3_PKGS[@]}"
