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

sudo pacman -Syu --needed --noconfirm "${WORK_PKGS[@]}"

yays \
  google-cloud-sdk \
  python-pre-commit \
  terraform-docs-bin \
  zoom

sudo systemctl enable docker
if ! id -nG "$USERNAME" | grep -qw docker; then
  sudo usermod -G docker -a "$USERNAME"
fi
