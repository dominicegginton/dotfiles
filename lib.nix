{ self }:

rec {
  # Domain identification.
  domain = "dominicegginton.dev";

  # Tailnet domain identification.
  tailnet = "soay-puffin.ts.net";

  # Hostnames derived from each NixOS configuration.
  hostnames = self.inputs.nixpkgs.lib.attrNames self.outputs.nixosConfigurations;

  # Define and merge additional maintainers with the existing nixpkgs maintainers.
  maintainers = self.inputs.nixpkgs.lib.recursiveUpdate self.inputs.nixpkgs.lib.maintainers {

    # Dominic Egginton.
    # Roles: Owner, Admin, User.
    dominicegginton = {
      name = "Dominic Egginton";
      email = "dominic.egginton@gmail.com";
      github = "dominicegginton";
      githubId = 28626241;
      sshKeys = [ "ssh-rsa4096/4C79CE4F82847A9F" ];
    };
  };

  # Function to construct a NixOS system using the flake inputs/outputs.
  nixosSystem =
    {
      # Hostname of the NixOS system.
      hostname,
      # Platform of the NixOS system.
      platform ? "x86_64-linux",
      # Extra NixOS modules to include for this system.
      modules ? [ ],
      ...
    }:
    self.inputs.nixpkgs.lib.nixosSystem {
      # Set the Nix packages for this system to the appropriate platform.
      pkgs = self.outputs.nixpkgsFor.${platform};

      # Set special arguments for the NixOS system, so that includes nix
      # modules have access to these arguments.
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
        modules
        ++ [
          nix-topology.nixosModules.default
          base16.nixosModule
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.default
          run0-sudo-shim.nixosModules.default
          deadman.nixosModules.default
          # dit0.nixosModules.default
          ./modules
        ];
    };
}
