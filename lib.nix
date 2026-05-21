{ self }:

rec {
  # Primary domain for the infrastructure
  domain = "dominicegginton.dev";

  # Tailscale network domain
  tailnet = "soay-puffin.ts.net";

  # Hostnames defined in the flake outputs
  hostnames = self.inputs.nixpkgs.lib.attrNames self.outputs.nixosConfigurations;

  # Custom maintainer definitions merged with nixpkgs
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
  nixosSystem =
    {
      hostname,
      # Default to x86_64-linux
      platform ? "x86_64-linux",
      # Extra modules to include
      modules ? [ ],
      ...
    }:

    self.inputs.nixpkgs.lib.nixosSystem {
      # Use nixpkgs instance from flake outputs
      pkgs = self.outputs.nixpkgsFor.${platform};

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
          home-manager.nixosModules.default
          run0-sudo-shim.nixosModules.default
          deadman.nixosModules.default
          # dit0.nixosModules.default
          ./modules
        ]
        ++ modules;
    };
}
