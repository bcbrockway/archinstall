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
