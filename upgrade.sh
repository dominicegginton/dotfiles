#!/bin/sh -e

script_path=$(dirname "$(realpath "$0")")

sudo ln -sf "$script_path"/flake.nix /etc/nixos/flake.nix
sudo nix-channel --update
sudo nixos-rebuild switch --flake ".#$1" --upgrade-all
sudo nix-env -u '*'
