{ inputs, outputs, lib, stateVersion, theme, tailnet }:

lib // rec {
  inherit theme tailnet;
  eachPlatformMerge = op: platforms: f: builtins.foldl' (op f) { } (if !builtins ? currentSystem || builtins.elem builtins.currentSystem platforms then platforms else platforms ++ [ builtins.currentSystem ]);
  eachPlatform = eachPlatformMerge (f: attrs: platform: let ret = f platform; in builtins.foldl' (attrs: key: attrs // { ${key} = (attrs.${key} or { }) // { ${platform} = ret.${key}; }; }) attrs (builtins.attrNames ret));
  packagesFrom = module: platform: module.packages.${platform};
  nixosSystem = { hostname, platform ? "x86_64-linux", specialArgs ? { }, modules ? [ ], ... } @args:
    inputs.nixpkgs.lib.nixosSystem ((builtins.removeAttrs args [ "hostname" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = (args.specialArgs or { }) // { inherit inputs outputs stateVersion hostname theme tailnet; };
      modules = [
        inputs.base16.nixosModule
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.default
        inputs.nix-topology.nixosModules.default
        (if hostname == "nixos-installer" then inputs.nixos-images.nixosModules.image-installer else ./modules/nixos)
        (if hostname == "nixos-installer" then ./modules/nixos/console.nix else { })
        (if hostname == "nixos-installer" then ./modules/nixos/nix-settings.nix else { })
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./hosts/nixos/${hostname}/default.nix)
        {
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
          home-manager.extraSpecialArgs = specialArgs;
        }
      ] ++ (args.modules or [ ]);
    });
  darwinSystem = { hostname, platform ? "x86_64-darwin", specialArgs ? { }, modules ? [ ], ... } @args:
    inputs.nix-darwin.lib.darwinSystem ((builtins.removeAttrs args [ "hostname" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = (args.specialArgs or { }) // { inherit inputs outputs stateVersion hostname theme tailnet; };
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
