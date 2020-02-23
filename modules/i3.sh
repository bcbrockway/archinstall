#!/bin/bash

readarray -t I3_PKGS < "$ROOT/pkgs/i3.txt" && export I3_PKGS

arch-chroot "$ARCH" pacman -S --needed --noconfirm "${I3_PKGS[@]}"
