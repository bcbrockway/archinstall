#!/bin/bash

set -e

source common.sh

export WORK_PKGS=(
  docker
  docker-compose
  git-crypt
  go
  jq
  kubectl
  kubectx
  python-toml
  vault
  virtualbox
  yamllint
  yubico-pam
)

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
