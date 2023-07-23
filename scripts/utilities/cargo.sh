#!/usr/bin/env sh

function cargo_install () {
  PACKAGES=$@
  sudo cargo install $PACKAGES
}
