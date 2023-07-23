#!/usr/bin/env sh

source scripts/utilities/pacman.sh
source scripts/utilities/aur.sh
source scripts/utilities/cargo.sh
source scripts/utilities/npm.sh
source scripts/utilities/nvm.sh
source scripts/utilities/bob.sh

pacman_clear_cache

packman_install         \
  "base-devel"  \
  "git"         \
  "bash"        \
  "zsh"         \
  "python"      \
  "python-pip"  \
  "nodejs"      \
  "npm"         \
  "rust"        \
  "sway"        \
  "swaylock"    \
  "swayidle"    \
  "waybar"      \
  "wofi"        \
  "alacritty"   \
  "firefox"

install_nvm

npm_install "@bitwarden/cli" \
  "@vue/cli"                  \
  "eslint"                    \
  "prettier"                  \
  "typescript"                \
  "typescript-language-server" \
  "vscode-langservers-extracted" \
  "@angular/language-server" \

# aur_install "bob" "paru"
