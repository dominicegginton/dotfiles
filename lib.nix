## lib.nix
#
# Custom library functions and helpers for use throughout the dotfiles flake.
# These functions extend the standard nixpkgs library and provide domain-specific
# logic for managing infrastructure, hostnames, and system configurations.
#
# This file is imported as self.outputs.lib and merged with nixpkgs lib in overlays.nix.

{ self }:

let
  inherit (self.inputs.nixpkgs) lib;
in

rec {
  # Primary domain for the infrastructure (used for FQDNs, certs, etc.)
  domain = "dominicegginton.dev";

  # Tailscale network domain used for mesh networking
  tailnet = "soay-puffin.ts.net";

  # Hostnames defined in the flake outputs, extracted from nixosConfigurations
  hostnames = lib.attrNames self.outputs.nixosConfigurations;

  # Custom maintainer definitions merged with nixpkgs.
  # This allows using personal maintainer info in package definitions and overlays.
  maintainers = import ./lib/maintainers.nix { inherit lib; };

  # Terraform helpers for declarative, reproducible infrastructure builds
  terraform = pkgs: import ./lib/terraform.nix { inherit pkgs; };

  # Helper to define a NixOS system with standard defaults
  # Used in flake.nix for all host definitions
  nixosSystem = import ./lib/nixos.nix { inherit self tailnet; };
}
