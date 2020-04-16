#!/bin/bash

export I3_PKGS=(
  arandr
  i3-gaps
  dmenu
  feh
  perl-anyevent-i3
)

arch-chroot "$ARCH" pacman -Syu --needed --noconfirm "${I3_PKGS[@]}"
