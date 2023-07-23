#!/usr/bin/env sh

function install_nvm () {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | sh
}

function upgrade_nvm () {
  cd ~/.nvm
  git fetch --tags origin
  git checkout `git describe --abbrev=0 --tags`
  cd -
}
