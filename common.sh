#!/bin/bash

source scripts/dotenv
.env --file settings.env export

ARCH="/mnt"
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export ARCH ROOT

function yays {
  local packages; packages=("$@")

  for package in "${packages[@]}"; do
    if ! yay -Qi "$package" > /dev/null 2>&1; then
      echo "Installing package: $package"
      yay -S -a --answerdiff N --answerclean A --needed --noconfirm --quiet "$package"
    else
      echo "Package $package already installed. Skipping..."
    fi
  done
}

function pacmans {
  local packages; packages=("$@")
  pacman -S --needed --noconfirm "${packages[@]}"
}

function key_value {
  local key; key=$1
  local value; value=$2
  local filename; filename=$3

  if grep -P "^$key=" "$filename" > /dev/null 2>&1; then
    sed --in-place "s/^$key=.*/$key=$value/" "$filename"
  else
    echo "$key=$value" >> "$filename"
  fi
}

function snap_install {
  local package; package=$1
  local opts; opts=("${@:2}")

  if ! snap list "$package" >/dev/null 2>&1; then
    snap install "$package" "${opts[@]}"
  fi
}

function panic {
  echo "$@"
  exit 1
}
