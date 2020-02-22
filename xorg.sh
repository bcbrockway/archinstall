#!/bin/bash

set -ex

source common.sh

# Video drivers
case "$VIDEO" in
  nvidia)
    video_driver=nvidia
    ;;
  intel)
    video_driver=xf86-video-intel
    ;;
  vmware)
    video_driver=xf86-video-vmware
    ;;
  *)
    panic "Only nvidia, intel and vmware supported"
esac

pacmans \
  "$video_driver" \
  lightdm \
  xf86-input-libinput \
  xorg-server \
  xorg-xrandr \
  xorg-xrdb

# Configure xorg
copy etc/X11/xorg.conf.d/00-keyboard.conf
copy etc/X11/xorg.conf.d/30-touchpad.conf
