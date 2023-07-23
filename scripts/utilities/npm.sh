#!/usr/bin/env sh

function npm_install () {
  PACKAGES=$@
  sudo npm install -g $PACKAGES
}
