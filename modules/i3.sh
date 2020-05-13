#!/bin/bash

export I3_PKGS=(
  arandr
  blueman
  dmenu
  feh
  i3-gaps
  i3status
  network-manager-applet
  pavucontrol
  perl-anyevent-i3
  polybar
  udiskie
  volctl
)

arch-chroot "$ARCH" pacman -Syu --needed --noconfirm "${I3_PKGS[@]}"
