#!/usr/bin/env sh

function aur_install () {
  PACKAGES=$@
  for PACKAGE in $PACKAGES; do
    git clone https://aur.archlinux.org/$PACKAGE.git /tmp/$PACKAGE
    cd /tmp/$PACKAGE
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/$PACKAGE
  done
}
