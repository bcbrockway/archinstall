#!/bin/bash

readarray -t XORG_PKGS < "$ROOT/pkgs/xorg.txt" && export XORG_PKGS

case "$VIDEO" in
  nvidia)
    XORG_PKGS+=(nvidia)
    ;;
  intel)
    XORG_PKGS+=(xf86-video-intel)
    ;;
  vmware)
    XORG_PKGS+=(virtualbox-guest-utils xf86-video-vmware virtualbox-guest-modules-arch)
    ;;
  *)
    panic "Only nvidia, intel and vmware supported"
esac

arch-chroot "$ARCH" pacman -S --needed --noconfirm "${XORG_PKGS[@]}"

if [[ "$VIDEO" == vmware ]]; then
  arch-chroot "$ARCH" systemctl enable vboxservice
  arch-chroot "$ARCH" usermod -G vboxsf -a "$USERNAME"
fi

# Configure xorg
cp etc/X11/xorg.conf.d/00-keyboard.conf "$ARCH/etc/X11/xorg.conf.d/00-keyboard.conf"
cp etc/X11/xorg.conf.d/30-touchpad.conf "$ARCH/etc/X11/xorg.conf.d/30-touchpad.conf"
