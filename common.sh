#!/bin/bash

source dotenv

.env --file settings.env export
export ARCH="/mnt"

function yays {
  local packages; packages=("$@")

  for package in "${packages[@]}"; do
    if ! yay -Qi "$package" > /dev/null 2>&1; then
      echo "Installing package: $package"
      sudo yay -S -a --answerdiff N --answerclean A --needed --noconfirm --quiet "$package"
    else
      echo "Package $package already installed. Skipping..."
    fi
  done
}

function pacmans {
  local packages; packages=("$@")
  sudo pacman -S --needed --noconfirm "${packages[@]}"
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

function copy {
  export COPIED=false
  local src; src=$1
  local dst; dst=${2:-/$src}

  if [[ $src =~ ^(\.\.|~|/) ]]; then
    echo "src references file outside this context ($src)"
    exit 1
  fi
  if [[ ! -e $src ]]; then
    echo "src file does not exist ($src)"
    exit 1
  fi

  if [[ -e "$dst" ]]; then
    if ! diff "$dst" "$src"; then
      echo "File $dst exists and is different. What would you like to do?"
      echo -n "[r]eplace [s]kip (default) [a]bort: "
      read -n 1 ans
      if [[ $ans == "r" ]]; then
        cp -r "$src" "$dst"
	COPIED=true
	return 0
      elif [[ $ans == "s" ]] || [[ -z $ans ]]; then
        return 0
      elif [[ $ans == "a" ]]; then
        exit 1
      fi
    fi
  else
    cp -r "$src" "$dst"
    COPIED=true
    return 0
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
