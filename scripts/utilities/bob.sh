#!/usr/bin/env sh

function bob_install () {
  VERSION=$1
  bob install $VERSION
}

function bob_use () {
  VERSION=$1
  bob use $VERSION
}
