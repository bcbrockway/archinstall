#!/bin/bash

set -e

source common.sh
.env --file install.env export

export MY_PKGS=(
  chromium
  firefox
  insync
)

yays "${MY_PKGS[@]}"

# Oh My Zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [[ ! $SHELL =~ .*/zsh ]]; then
  chsh -s /bin/zsh
fi

echo "Install work packages? [Y/n]: "
read -r install_work
if [[ ! "$install_work" =~ [Nn] ]]; then
  "$ROOT/modules/work.sh"
fi

echo "Update dotfiles? [Y/n]: "
read -r update_dotfiles
if [[ ! "$update_dotfiles" =~ [Nn] ]]; then
  yadm clone https://github.com/bcbrockway/dotfiles.git
  yadm reset --hard origin/master
fi
