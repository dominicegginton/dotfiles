#!/usr/bin/env sh

# Dotfiles By Dominic Egginton
# https://github.com/dominicegginton/dotfiles
# There's no place like ~

# 1. Get operating system
OPERATING_SYSTEM=$(uname -s)

# 2. Exit if operating system is not supported
if [ $OPERATING_SYSTEM = "MINGW64_NT-10.0" ]; then
  exit 1
fi

# 3. Run installation script for operating system
if [ $OPERATING_SYSTEM = "Darwin" ]; then
  sh ./install-macos.sh
  exit 0
elif [ $OPERATING_SYSTEM = "Linux" ]; then
  sh ./install-linux.sh
  exit 0
fi
