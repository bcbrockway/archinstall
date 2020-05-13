#!/bin/bash

set -e

source common.sh

export WORK_PKGS=(
  chromium
  dnsmasq
  docker
  docker-compose
  git-crypt
  go
  httpie
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

cp etc/docker/daemon.json /etc/docker/daemon.json
if ! id -nG "$USERNAME" | grep -qw docker; then
  sudo usermod -G docker -a "$USERNAME"
fi

cp etc/NetworkManager/conf.d/dns.conf /etc/NetworkManager/conf.d/dns.conf
cp etc/NetworkManager/dispatcher.d/10-mintel-vpn-rerouting /etc/NetworkManager/dispatcher.d/10-mintel-vpn-rerouting
cp etc/NetworkManager/dnsmasq.d/90-docker /etc/NetworkManager/dnsmasq.d/90-docker

cp etc/systemd/system/docker-dnsdock.service /etc/systemd/system/docker-dnsdock.service
cp etc/systemd/system/docker-system-dnsmasq.service /etc/systemd/system/docker-system-dnsmasq.service

sudo systemctl daemon-reload
sudo systemctl enable docker --now
sudo systemctl enable docker-system-dnsmasq --now
sudo systemctl enable docker-dnsdock --now
