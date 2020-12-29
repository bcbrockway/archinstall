#!/bin/bash

set -e

source common.sh
.env --file install.env export

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

yays "${I3_PKGS[@]}"

# Cursors
sudo cp usr/share/icons/default/index.theme /usr/share/icons/default/index.theme

echo "Setting default lightdm session to i3"
sudo sed -i "s/#*\(autologin-session\)=.*/\1=i3/g" /etc/lightdm/lightdm.conf

