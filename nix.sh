#!/bin/sh -e

sudo sed -i "/^experimental-features.*/d" /etc/nix/nix.conf
sudo sh -c 'printf "experimental-features = nix-command flakes\n" >> /etc/nix/nix.conf'

nix build --no-link ".#homeConfigurations.\"$1\".activationPackage"
"$(nix path-info .\#homeConfigurations."$1".activationPackage)"/activate

home-manager switch --flake ".#$1"
