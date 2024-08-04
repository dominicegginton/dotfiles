{ inputs, outputs, stateVersion }:

let
  pkgsFor = platform: outputs.legacyPackages.${platform};

  specialArgsFor =
    { hostname
    , platform
    }: {
      inherit
        inputs
        outputs
        stateVersion
        hostname
        ;
    };
in

with inputs.nixpkgs.lib;
with inputs.nix-darwin.lib;
with inputs.home-manager.lib;

rec {
  mkNixosHost =
    { hostname
    , installer ? null
    , platform ? "x86_64-linux"
    }:
    nixosSystem {
      pkgs = pkgsFor platform;
      modules = [ ./hosts/nixos ] ++ (optionals (installer != null) [ installer ]);
      specialArgs = specialArgsFor { inherit hostname platform; };
    };

  mkDarwinHost =
    { hostname
    , username
    , platform ? "x86_64-darwin"
    }:
    darwinSystem {
      pkgs = pkgsFor platform;
      modules = [ ./hosts/darwin ];
      specialArgs = { inherit username; } // specialArgsFor { inherit hostname platform; };
    };

  mkHome =
    { hostname
    , username
    , platform ? "x86_64-linux"
    , desktop ? null
    }:
    homeManagerConfiguration {
      pkgs = pkgsFor platform;
      modules = [ ./home ];
      extraSpecialArgs = { inherit username desktop; } // specialArgsFor { inherit hostname platform; };
    };

  packagesFrom = module: attrs @ { system }:
    module.packages.${system};

  defaultPackageFrom = module: attrs @ { system }:
    (packagesFrom module attrs).default;
}
