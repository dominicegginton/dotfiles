#!/usr/bin/env sh

# Dotfiles By Dominic Egginton
# https://github.com/dominicegginton/dotfiles
# There's no place like ~

OPERATING_SYSTEM=$(uname -s)
if [ $OPERATING_SYSTEM != "Linux" ]; then
  exit 1
fi
