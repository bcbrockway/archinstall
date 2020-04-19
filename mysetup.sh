#!/bin/bash

set -e

source common.sh
.env --file install.env export

export MY_PKGS=(
  insync
)

yays "${MY_PKGS[@]}"

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
