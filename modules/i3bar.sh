#!/bin/bash

export I3BAR_PKGS=(
  blueman
  i3status
  network-manager-applet
  pasystray
  udiskie
)

arch-chroot "$ARCH" pacmans "${I3BAR_PKGS[@]}"
