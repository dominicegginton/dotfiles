{
  inputs,
  outputs,
  stateVersion,
  ...
}: {
  forAllPlatforms = inputs.nixpkgs.lib.genAttrs ["x86_64-linux" "x86_64-darwin"];

  mkNixosConfiguration = {
    hostname,
    installer ? null,
    platform ? "x86_64-linux",
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          hostname
          platform
          stateVersion
          ;
      };

      modules =
        [../hosts/nixos.nix]
        ++ (inputs.nixpkgs.lib.optionals (installer != null) [installer]);
    };

  mkDarwinConfiguration = {
    hostname,
    username,
  }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          hostname
          username
          stateVersion
          ;
        platform = "x86_64-darwin";
      };
      modules = [../hosts/darwin.nix];
    };

  mkHomeConfiguration = {
    hostname,
    username,
    desktop ? null,
    platform ? "x86_64-linux",
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = outputs.packages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          ;
      };
      modules = [../home/home.nix];
    };
}
