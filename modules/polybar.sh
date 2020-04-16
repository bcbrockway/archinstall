#!/bin/bash

export POLYBAR_PKGS=(
  arandr
  blueman
  i3-gaps
  i3status
  dmenu
  feh
  network-manager-applet
  pasystray
  perl-anyevent-i3
  rxvt-unicode
  udiskie
)

arch-chroot "$ARCH" pacmans "${I3_PKGS[@]}"
