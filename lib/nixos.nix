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
  ...
}:

let
  nixpkgsLib = self.inputs.nixpkgs.lib;
  lib = nixpkgsLib.extend (
    _: prev:
    prev
    // {
      inherit (self.outputs.lib) mkHardenedSystemdServiceConfig;
    }
  );
in
lib.nixosSystem {
  pkgs = self.outputs.legacyPackages.${platform};

  specialArgs = {
    inherit
      lib
      self
      tailnet
      hostname
      platform
      ;
  };

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
      driftwm.nixosModules.default
      jovian.nixosModules.default
      # velvet.nixosModules.default
      run0-sudo-shim.nixosModules.default
      ../modules
      ../hosts/${hostname}.nix
    ]
    ++ modules;
}
