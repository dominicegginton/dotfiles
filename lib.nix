{ inputs
, outputs
, stateVersion
}:

with inputs.nixpkgs.lib;
with inputs.nix-darwin.lib;
with inputs.home-manager.lib;

let
  pkgs = platform: outputs.packages.${platform};
in

{
  mkNixosHost =
    { hostname
    , installer ? null
    , platform ? "x86_64-linux"
    }:
    nixosSystem {
      inherit pkgs;

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
    darwinSystem {
      inherit pkgs;

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
    homeManagerConfiguration {
      inherit pkgs;

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
