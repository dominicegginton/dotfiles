#!/usr/bin/env bash

set -euo pipefail

TARGET_HOST="${1:-}"
TARGET_USER="${2:-dom}"

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi

if [ ! -d "$HOME/.dotfiles/.git" ]; then
  git clone https://github.com/dominicegginton/dotfiles.git "$HOME/.dotfiles"
fi

pushd "$HOME/.dotfiles"

if [[ -z "$TARGET_HOST" ]]; then
  echo "ERROR! $(basename "$0") requires a hostname as the first argument"
  echo "       The following hosts are available"
  ls -1 nixos/hosts/*/default.nix | cut -d'/' -f2 | grep -v iso
  exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
  echo "ERROR! $(basename "$0") requires a username as the second argument"
  echo "       The following users are available"
  ls -1 nixos/users/ | grep -v -E "nixos|root"
  exit 1
fi

if [ ! -e "nixos/$TARGET_HOST/disks.nix" ]; then
  echo "ERROR! $(basename "$0") could not find the required nixos/hosts/$TARGET_HOST/disks.nix"
  exit 1
fi

if grep -q "data.keyfile" "nixos/hosts/$TARGET_HOST/disks.nix"; then
  echo -n "$(head -c32 /dev/random | base64)" > /tmp/data.keyfile
fi

echo "WARNING! The disks in $TARGET_HOST are about to get wiped"
echo "         NixOS will be re-installed"
echo "         This is a destructive operation"
echo
read -p "Are you sure? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo true

  sudo nix run github:nix-community/disko \
    --extra-experimental-features "nix-command flakes" \
    --no-write-lock-file \
    -- \
    --mode zap_create_mount \
    "nixos/hosts/$TARGET_HOST/disks.nix"

  sudo nixos-install --no-root-password --flake ".#$TARGET_HOST"

  rsync -a --delete "$HOME/.dotfiles" /mnt/home/$TARGET_USER/.dotfiles"
  pushd "/mnt/home/$TARGET_USER/.dotfiles"
  git remote set-url origin git@github.com:dominicegginton/dotfiles.git
  popd

  if [[ -f "/tmp/data.keyfile" ]]; then
    sudo cp /tmp/data.keyfile /mnt/etc/data.keyfile
    sudo chmod 0400 /mnt/etc/data.keyfile
  fi
fi
