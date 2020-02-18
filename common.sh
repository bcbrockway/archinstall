#!/bin/bash

export FULL_NAME="Bobby Brockway"
export EMAIL_ADDRESS="bbrockway@mintel.com"

export USERNAME="bbrockway"
export TERMINAL_FONT="ter-v32n"
export KEYMAP="uk"
export VIDEO="intel"
export TIMEZONE="Europe/London"
# List locales. Primary locale should be first!
export LOCALES=(en_GB.UTF-8 en_US.UTF-8)
export HOSTNAME="arch-desktop"

function require_aur {
  local package; package=$1

  if ! pacman -Qi "$package" > /dev/null 2>&1; then
    echo "Installing package: $package"
    sudo -u $USERNAME yay -S -a --answerdiff N --answerclean A --noconfirm "$package"
  else
    echo "Package $package already installed. Skipping..."
  fi
}

function key_value {
  local key; key=$1
  local value; value=$2
  local filename; filename=$3

  if grep -P "^$key=" $filename > /dev/null 2>&1; then
    sed --in-place "s/^$key=.*/$key=$value/" $filename
  else
    echo "$key=$value" >> $filename
  fi
}

function copy {
  export COPIED=false
  local src; src=$1
  local dst

  if [[ $src =~ ^(\.\.|~|/) ]]; then
    echo "src references file outside this context ($src)"
    exit 1
  fi
  if [[ ! -e $src ]]; then
    echo "src file does not exist ($src)"
    exit 1
  fi

  dst=/$src

  if [[ -e $dst ]]; then
    if ! diff $dst $src; then
      echo "File $dst exists and is different. What would you like to do?"
      echo -n "[r]eplace [s]kip (default) [a]bort: "
      read -n 1 ans
      if [[ $ans == "r" ]]; then
        cp -r $src $dst
	COPIED=true
	return 0
      elif [[ $ans == "s" ]] || [[ -z $ans ]]; then
        return 0
      elif [[ $ans == "a" ]]; then
        exit 1
      fi
    fi
  else
    cp -r $src $dst
    COPIED=true
    return 0
  fi
}

function snap_install {
  local package; package=$1
  local opts; opts="${@:2}"

  if ! snap list $package >/dev/null; then
    snap install $package $opts
  fi
}

pacman -Sy
