#!/bin/bash

set -e

source common.sh

work_pkgs=(
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

require_aur google-cloud-sdk
require_aur python-pre-commit
require_aur terraform-docs-bin
require_aur zoom

arch-chroot "$ARCH" systemctl enable docker --now
if ! id -nG "$USERNAME" | grep -qw docker; then
  usermod -G docker -a "$USERNAME"
fi
