{ inputs
, outputs
, stateVersion
}: {
  mkNixosHost =
    { hostname
    , installer ? null
    , platform ? "x86_64-linux"
    }:
    inputs.nixpkgs.lib.nixosSystem {
      pkgs = outputs.packages.${platform};
      specialArgs = {
        inherit
          inputs
          hostname
          platform
          stateVersion
          ;
      };
      modules =
        [ ./hosts/nixos.nix ]
        ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ]);
    };

  mkDarwinHost =
    { hostname
    , username
    }:
    inputs.nix-darwin.lib.darwinSystem {
      pkgs = outputs.packages."x86_64-darwin";
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
      modules = [ ./hosts/darwin.nix ];
    };

  mkHome =
    { hostname
    , username
    , desktop ? null
    , platform ? "x86_64-linux"
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = outputs.packages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          desktop
          hostname
          platform
          username
          stateVersion
          ;
      };
      modules = [ ./home/home.nix ];
    };
}
