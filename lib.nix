{ inputs, outputs, stateVersion, theme, tailnet }:

rec {
  inherit theme tailnet;
  eachPlatformMerge = op: systems: f: builtins.foldl' (op f) { } (if !builtins ? currentSystem || builtins.elem builtins.currentSystem systems then systems else systems ++ [ builtins.currentSystem ]);
  eachPlatform = eachPlatformMerge (f: attrs: system: let ret = f system; in builtins.foldl' (attrs: key: attrs // { ${key} = (attrs.${key} or { }) // { ${system} = ret.${key}; }; }) attrs (builtins.attrNames ret));
  packagesFrom = module: { system }: module.packages.${system};
  defaultPackageFrom = module: attrs @ { system }: (packagesFrom module attrs // { inherit system; }).default;
  nixosSystem =
    { hostname
    , platform ? "x86_64-linux"
    , specialArgs ? { }
    , modules ? [ ]
    , ...
    } @args:
    inputs.nixpkgs.lib.nixosSystem ((builtins.removeAttrs args [ "hostname" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = { inherit inputs outputs stateVersion hostname theme tailnet; } // (args.specialArgs or { });
      modules = [
        inputs.base16.nixosModule
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.default
        inputs.nix-topology.nixosModules.default
        (if hostname == "nixos-installer" then { } else ./modules/nixos)
        (if hostname == "nixos-installer" then ./modules/nixos/console.nix else { })
        (if hostname == "nixos-installer" then ./modules/nixos/nix-settings.nix else { })
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./hosts/nixos/${hostname}/default.nix)
        {
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
          home-manager.extraSpecialArgs = specialArgs;
        }
      ] ++ (args.modules or [ ]);
    });
  darwinSystem =
    { hostname
    , platform ? "x86_64-darwin"
    , specialArgs ? { }
    , modules ? [ ]
    , ...
    } @args:
    inputs.nix-darwin.lib.darwinSystem ((builtins.removeAttrs args [ "hostname" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = { inherit inputs outputs stateVersion hostname theme tailnet; } // (args.specialArgs or { });
      modules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-topology.darwinModules.default
        ./modules/darwin
        ./hosts/darwin/${hostname}.nix
        {
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
          home-manager.extraSpecialArgs = specialArgs;
        }
      ] ++ (args.modules or [ ]);
    });
}
