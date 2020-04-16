#!/bin/bash

export I3BAR_PKGS=(
  blueman
  i3status
  network-manager-applet
  pasystray
  udiskie
)

arch-chroot "$ARCH" pacman -Syu --needed --noconfirm "${I3BAR_PKGS[@]}"
