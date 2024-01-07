{
  inputs,
  outputs,
  stateVersion,
  ...
}: {
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "x86_64-darwin"
  ];

  mkNixosConfiguration = {
    hostname,
    username,
    desktop ? null,
    installer ? null,
    platform ? "x86_64-linux",
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules =
        [../nixos]
        ++ (inputs.nixpkgs.lib.optionals (installer != null) [installer]);
    };

  mkDarwinConfiguration = {
    hostname,
    username,
    desktop ? null,
    platform ? "x86_64-darwin",
  }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules = [../darwin];
    };

  mkHomeConfiguration = {
    hostname,
    username,
    desktop ? null,
    platform ? "x86_64-linux",
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules = [../home];
    };
}
