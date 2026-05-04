{ self }:

rec {
  # Set domain identification.
  domain = "dominicegginton.dev";

  # Set Tailnet domain identification.
  tailnet = "soay-puffin.ts.net";

  # Names of hosts derived from each NixOS configuration.
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

  # Function to construct a NixOS host system using the flake inputs/outputs.
  nixosSystem =
    {
      # Name of the host for the NixOS configuration.
      hostname,
      # The platform architecture for the NixOS configuration.
      # Default to `x86_64-linux`.
      platform ? "x86_64-linux",
      # Extra NixOS modules to be included for this NixOS
      # configuration.
      modules ? [ ],
      ...
    }:

    self.inputs.nixpkgs.lib.nixosSystem {
      # Set the Nix packages for the NixOS configuration
      # modules to use by default to the appropriate platform
      # nixpkgs defined by this flake.
      pkgs = self.outputs.nixpkgsFor.${platform};

      # Set special arguments for the NixOS configuration
      # modules to be called with these arguments.
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
