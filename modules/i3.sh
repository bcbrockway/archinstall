#!/bin/bash

export I3_PKGS=(
  arandr
  dmenu
  feh
  i3-gaps
  i3status
  perl-anyevent-i3
)

arch-chroot "$ARCH" pacman -Syu --needed --noconfirm "${I3_PKGS[@]}"
