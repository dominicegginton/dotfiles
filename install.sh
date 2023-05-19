#!/usr/bin/env sh

# Dotfiles By Dominic Egginton
# https://github.com/dominicegginton/dotfiles
# There's no place like ~

# This script calls the appropriate install script for the current operating system.
# If the operating system is not supported, the script exits with an error code.

OPERATING_SYSTEM=$(uname -s)
if [ $OPERATING_SYSTEM = "Darwin" ]; then
  sh ./install-macos.sh
  exit 0
elif [ $OPERATING_SYSTEM = "Linux" ]; then
  sh ./install-linux.sh
  exit 0
fi
exit 1
