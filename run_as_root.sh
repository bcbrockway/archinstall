#!/bin/bash

set -e

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$THISDIR"

source common.sh

#################
# Core Packages #
#################

echo "Installing packages"
pacman -Sy --needed --noconfirm --quiet \
  ack \
  arandr \
  base-devel \
  bluez \
  bluez-utils \
  blueman \
  chromium \
  curl \
  dmenu \
  docker \
  docker-compose \
  feh \
  fwupd \
  git \
  go \
  i3-wm \
  i3lock \
  i3status \
  git-crypt \
  jq \
  kubectl \
  kubectx \
  libnotify \
  light \
  man \
  mesa \
  mlocate \
  networkmanager \
  network-manager-applet \
  notification-daemon \
  pasystray \
  pbzip2 \
  pulseaudio \
  pulseaudio-bluetooth \
  pigz \
  python \
  python-toml \
  openssh \
  rsync \
  stow \
  terminator \
  tree \
  ttf-dejavu \
  udiskie \
  unzip \
  vault \
  vim \
  virtualbox \
  virtualbox-host-modules-arch \
  wget \
  xf86-input-libinput \
  xf86-video-intel \
  xorg-server \
  xorg-xrandr \
  xorg-xrdb \
  xz \
  yamllint \
  yubico-pam \
  zsh \
  zstd

systemctl enable bluetooth --now
systemctl enable sshd --now
systemctl enable NetworkManager --now
systemctl enable docker --now

if ! id -nG $USERNAME | grep -qw docker; then
  usermod -G docker -a $USERNAME
fi

################
# AUR Packages #
################

require_aur breeze-adapta-cursor-theme-git
require_aur google-cloud-sdk
require_aur i3lock-fancy-git
require_aur insync
require_aur python-pre-commit
require_aur snapd
require_aur terraform-docs-bin
require_aur vim-plug
require_aur yq-bin
require_aur zoom

#################
# Snap Packages #
#################
echo "Snap config"
if ! systemctl is-active --quiet snapd.socket; then
  systemctl enable --now snapd.socket
fi
if [[ ! -h /snap ]]; then
  ln -s /var/lib/snapd/snap /snap
  echo "Snap needs to reboot your system. Ok? [y/n]: "
  read -n1 ans
  if [[ $ans =~ [Yy] ]]; then
    reboot
  else
    touch /tmp/REBOOT_REQUIRED
  fi
fi
if [[ ! -f /tmp/REBOOT_REQUIRED ]]; then
  snap_install goland --classic
fi

###########
# Cursors #
###########
echo "Checking cursor config"
copy usr/share/icons/default/index.theme

#######
# Git #
#######
echo "Checking git config"
sudo -u $USERNAME bash <<EOF
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL_ADDRESS"
git config --global core.excludesfile ~/.gitignore-global
EOF

#############
# Oh My Zsh #
#############
echo "Checking zsh config"
sudo -u $USERNAME bash <<'EOF'
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [[ $SHELL != /bin/zsh ]]; then
  chsh -s /bin/zsh
fi
EOF

echo "Script complete"
