#!/usr/bin/env sh

# Dotfiles By Dominic Egginton
# https://github.com/dominicegginton/dotfiles
# There's no place like ~

# 1. Get Operating System
OPERATING_SYSTEM=$(uname -s)

# 2. Exit if Operating System is not supported
if [ $OPERATING_SYSTEM != "Linux" ]; then
  exit 1
fi
