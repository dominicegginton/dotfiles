# lib/nixos.nix
#
# Custom system builder helper for creating unified NixOS hosts with sane,
# standardized modules and consistent execution environments.

{ self, tailnet }:

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
      jovian.nixosModules.default
      ../modules
      ../hosts/${hostname}.nix
    ]
    # find a better way to disable this
    ++ (lib.optional (hostname != "MCCLT5CG53030HM-wsl") run0-sudo-shim.nixosModules.default)
    ++ (lib.optional (user != null) ../modules/users/${user}.nix)
    ++ modules;
}
