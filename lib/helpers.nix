{
  inputs,
  outputs,
  stateVersion,
  darwinStateVersion,
  ...
}: {
  mkHome = {
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
      modules = [../home-manager];
    };

  mkHost = {
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
        [
          ../nixos
        ]
        ++ (inputs.nixpkgs.lib.optionals (installer != null) [installer]);
    };

  mkDarwinHost = {
    hostname,
    username,
    platform ? "x86_64-darwin",
  }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs outputs hostname platform darwinStateVersion;
      };
      modules = [../darwin];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
