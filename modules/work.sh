#!/bin/bash

set -e

source common.sh

readarray -t WORK_PKGS < "$ROOT/pkgs/i3.txt" && export WORK_PKGS

sudo pacman -S --needed --noconfirm "${WORK_PKGS[@]}"
yays \
  google-cloud-sdk \
  python-pre-commit \
  terraform-docs-bin \
  zoom

arch-chroot "$ARCH" systemctl enable docker --now
if ! id -nG "$USERNAME" | grep -qw docker; then
  usermod -G docker -a "$USERNAME"
fi
