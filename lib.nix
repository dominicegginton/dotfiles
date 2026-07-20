## lib.nix
#
# Custom library functions and helpers for use throughout the dotfiles flake.
# These functions extend the standard nixpkgs library and provide domain-specific
# logic for managing infrastructure, hostnames, and system configurations.
#
# This file is imported as self.outputs.lib and merged with nixpkgs lib in overlays.nix.

{ self }:

rec {
  # Primary domain for the infrastructure (used for FQDNs, certs, etc.)
  domain = "dominicegginton.dev";

  # Tailscale network domain used for mesh networking
  tailnet = "soay-puffin.ts.net";

  # Hostnames defined in the flake outputs, extracted from nixosConfigurations
  hostnames = self.inputs.nixpkgs.lib.attrNames self.outputs.nixosConfigurations;

  # Custom maintainer definitions merged with nixpkgs.
  # This allows using personal maintainer info in package definitions and overlays.
  maintainers = self.inputs.nixpkgs.lib.recursiveUpdate self.inputs.nixpkgs.lib.maintainers {

    # Dominic Egginton
    dominicegginton = {
      name = "Dominic Egginton";
      email = "dominic.egginton@gmail.com";
      github = "dominicegginton";
      githubId = 28626241;
      sshKeys = [ "ssh-rsa4096/4C79CE4F82847A9F" ];
    };
  };

  # Helper to define a NixOS system with standard defaults
  # Used in flake.nix for all host definitions
  nixosSystem =
    {
      hostname,
      # Default to x86_64-linux
      platform ? "x86_64-linux",
      # Extra modules to include
      modules ? [ ],
      # Default user to include
      user ? "dom",
      ...
    }:

    let
      lib = self.inputs.nixpkgs.lib;
    in

    lib.nixosSystem {
      # Use nixpkgs instance from flake outputs
      pkgs = self.outputs.legacyPackages.${platform};

      # Pass self, inputs, and lib to all modules
      specialArgs = {
        inherit
          self
          tailnet
          hostname
          platform
          ;
      };

      # Define list of NixOS modules to include for all systems.
      modules =
        with self.inputs;
        [
          nix-topology.nixosModules.default
          nixos-wsl.nixosModules.default
          base16.nixosModule
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          home-manager.nixosModules.default
          deadman.nixosModules.default
          tsnsrv.nixosModules.default
          # dit0.nixosModules.default
          driftwm.nixosModules.default
          ./modules
          ./hosts/${hostname}.nix
        ]
        # find a better way to disable this
        ++ (lib.optional (hostname != "wsl") run0-sudo-shim.nixosModules.default)
        ++ (lib.optional (user != null) ./modules/users/${user}.nix)
        ++ modules;
    };
}
