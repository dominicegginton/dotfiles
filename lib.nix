{ inputs, outputs, nixConfig }:

rec {
  nixosStateVersion = "24.05";
  darwinStateVersion = 5;
  theme = "light";
  tailnet = "soay-puffin.ts.net";
  nixosHostnames = inputs.nixpkgs.lib.attrNames outputs.nixosConfigurations;
  darwinHostnames = inputs.nixpkgs.lib.attrNames outputs.darwinConfigurations;
  hostnames = nixosHostnames ++ darwinHostnames;
  maintainers = inputs.nixpkgs.lib.maintainers // {
    dominicegginton = {
      name = "Dominic Egginton";
      email = "dominic.egginton@gmail.com";
      github = "dominicegginton";
      githubId = 28626241;
    };
  };
  eachPlatformMerge = op: platforms: f: builtins.foldl' (op f) { } (if !builtins ? currentSystem || builtins.elem builtins.currentSystem platforms then platforms else platforms ++ [ builtins.currentSystem ]);
  eachPlatform = eachPlatformMerge (f: attrs: platform: let ret = f platform; in builtins.foldl' (attrs: key: attrs // { ${key} = (attrs.${key} or { }) // { ${platform} = ret.${key}; }; }) attrs (builtins.attrNames ret));
  packagesFrom = module: platform: module.packages.${platform};
  nixosSystem = { hostname, platform ? "x86_64-linux", ... } @args:
    inputs.nixpkgs.lib.nixosSystem ((builtins.removeAttrs args [ "hostname" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = (args.specialArgs or { }) // {
        inherit inputs outputs theme tailnet hostname nixConfig;
        stateVersion = nixosStateVersion;
        dlib = outputs.lib;
      };
      modules = [
        inputs.base16.nixosModule
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.default
        inputs.nix-topology.nixosModules.default
        (if hostname == "nixos-installer" then inputs.nixos-images.nixosModules.image-installer else ./modules/nixos)
        (if hostname == "nixos-installer" then ./modules/nixos/console.nix else { })
        (if hostname == "nixos-installer" then ./modules/nixos/nix-settings.nix else { })
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./hosts/nixos/${hostname}/default.nix)
        {
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
          home-manager = {
            extraSpecialArgs = specialArgs;
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              inputs.impermanence.homeManagerModules.impermanence
              inputs.plasma-manager.homeManagerModules.plasma-manager
              inputs.base16.nixosModule
              {
                scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
                home = { stateVersion = nixosStateVersion; };
              }
              ./modules/home-manager
            ];
            backupFileExtension = "backup";
          };
        }
      ] ++ (args.modules or [ ]);
    });
  darwinSystem = { hostname, platform ? "x86_64-darwin", ... } @args:
    inputs.nix-darwin.lib.darwinSystem ((builtins.removeAttrs args [ "hostname" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = (args.specialArgs or { }) // {
        inherit inputs outputs theme tailnet hostname;
        stateVersion = darwinStateVersion;
        dlib = outputs.lib;
      };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        ./modules/darwin
        ./hosts/darwin/${hostname}.nix
        {
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            inputs.impermanence.homeManagerModules.impermanence
            inputs.plasma-manager.homeManagerModules.plasma-manager
            inputs.base16.nixosModule
            {
              scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
              home.stateVersion = darwinStateVersion;
            }
            ./modules/home-manager
          ];

        }
      ] ++ (args.modules or [ ]);
    });
}
