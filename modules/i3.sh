#!/bin/bash

set -e

export I3_PKGS=(
  adobe-source-han-sans-jp-fonts
  alacritty
  arandr
  blueman
  breeze-adapta-cursor-theme-git
  chromium
  dmenu
  feh
  i3-gaps
  i3lock-fancy-rapid-git
  i3status
  network-manager-applet
  pavucontrol
  perl-anyevent-i3
  picom
  polybar
  udiskie
  volctl
)

source common.sh

yays "${I3_PKGS[@]}"

# Cursors
sudo cp usr/share/icons/default/index.theme /usr/share/icons/default/index.theme

