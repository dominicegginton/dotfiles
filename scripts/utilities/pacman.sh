#!/usr/bin/env sh

function pacman_clear_cache () {
  sudo pacman -Scc --noconfirm
}

function packman_install () {
  PACKAGES=$@
  sudo pacman -Sy --noconfirm $PACKAGES
}
