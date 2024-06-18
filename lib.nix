{ inputs
, outputs
, stateVersion
}:

let
  # the platform specific packages
  pkgsFor = platform: outputs.packages.${platform};

  # create aguments for that will be passed to all modules when evaulating
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
  # create a nixos host system
  mkNixosHost =
    { hostname
    , installer ? null
    , platform ? "x86_64-linux"
    }:
    nixosSystem {
      pkgs = pkgsFor platform;
      modules = [ ./hosts/nixos.nix ] ++ (optionals (installer != null) [ installer ]);
      specialArgs = specialArgsFor { inherit hostname platform; };
    };

  # create a darwin host system
  mkDarwinHost =
    { hostname
    , username
    , platform ? "x86_64-darwin"
    }:
    darwinSystem {
      pkgs = pkgsFor platform;
      modules = [ ./hosts/darwin.nix ];
      specialArgs = { inherit username; } // specialArgsFor { inherit hostname platform; };
    };

  # create a home configuration for a user
  mkHome =
    { hostname
    , username
    , platform ? "x86_64-linux"
    , desktop ? null
    }:
    homeManagerConfiguration {
      pkgs = pkgsFor platform;
      modules = [ ./home/home.nix ];
      extraSpecialArgs = { inherit username desktop; } // specialArgsFor { inherit hostname platform; };
    };

  # get packages from module
  packagesFrom = module: attrs @ { system }:
    module.packages.${system};

  # get default package from module
  defaultPackageFrom = module: attrs @ { system }:
    (packagesFrom module attrs).default;
}
