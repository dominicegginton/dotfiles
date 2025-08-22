{ inputs, outputs, nixConfig }:

let
  stateVersion = {
    nixos = "24.05";
    darwin = 5;
  };
  tailnet = "soay-puffin.ts.net";
  specialArgsFor = { hostname, stateVersion }: {
    inherit inputs outputs tailnet hostname stateVersion nixConfig;
    dlib = outputs.lib;
  };
in

rec {
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
  nixosSystem = args @ { hostname, platform ? "x86_64-linux", ... }:
    inputs.nixpkgs.lib.nixosSystem ((builtins.removeAttrs args [ "hostname" "platform" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = (specialArgsFor { inherit hostname; stateVersion = stateVersion.nixos; }) // (args.specialArgs or { });
      modules =
        if (!args ? modules) then [
          inputs.base16.nixosModule
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.default
          inputs.nix-topology.nixosModules.default
          ./hosts/nixos/${hostname}.nix
          ./modules/nixos
          ({ config, lib, pkgs, nixConfig, stateVersion, ... }:
            rec {
              system = {
                inherit stateVersion;
                nixos = {
                  distroName = lib.mkDefault "Residence";
                  distroId = lib.mkDefault "residence";
                  vendorName = lib.mkDefault pkgs.lib.maintainers.dominicegginton.name;
                  vendorId = lib.mkDefault pkgs.lib.maintainers.dominicegginton.github;
                  tags = [
                    (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux")
                    (lib.optionalString (pkgs.stdenv.isDarwin) "residence-darwin")
                  ];
                };
              };
              time.timeZone = "Europe/London";
              i18n.defaultLocale = "en_GB.UTF-8";
              nix = {
                package = pkgs.unstable.nix;
                gc = {
                  automatic = true;
                  dates = "weekly";
                  options = "--delete-older-than 30d";
                };
                optimise.automatic = lib.mkDefault true;
                registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
                nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
                settings = nixConfig // {
                  min-free = "8G";
                  max-free = "10G";
                  min-free-check-interval = 1;
                  trusted-users = [ "dom" "root" "@wheel" ];
                };
              };
              documentation = {
                enable = true;
                man.enable = true;
                doc.enable = true;
                dev.enable = true;
                info.enable = true;
              };
              console = {
                enable = true;
                earlySetup = true;
                keyMap = "uk";
                font = "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
                colors = config.scheme.toList;
              };
              programs = {
                zsh = {
                  enable = true;
                  enableCompletion = true;
                  autosuggestions.enable = true;
                  promptInit = "autoload -U promptinit && promptinit";
                };
                gnupg.agent = {
                  enable = true;
                  pinentryPackage = pkgs.pinentry;
                };
                command-not-found.enable = true;
              };
              hardware.cpu = {
                intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
                amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
              };
              scheme = "${pkgs.theme}/theme.yaml";
              home-manager = {
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [
                  inputs.impermanence.homeManagerModules.impermanence
                  inputs.base16.homeManagerModule
                  inputs.ags.homeManagerModules.default
                  {
                    inherit scheme;
                    home = { inherit stateVersion; };
                  }
                  ./modules/home-manager
                ];
                backupFileExtension = "backup";
              };
            })
        ] else args.modules;
    });
  darwinSystem = { hostname, platform ? "x86_64-darwin", ... } @args:
    inputs.nix-darwin.lib.darwinSystem ((builtins.removeAttrs args [ "hostname" "platform" ]) // rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = (specialArgsFor { inherit hostname; stateVersion = stateVersion.darwin; }) // (args.specialArgs or { });
      modules = [
        inputs.home-manager.darwinModules.home-manager
        ./modules/darwin
        ./hosts/darwin/${hostname}.nix
        ({ pkgs, ... }: {
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            inputs.impermanence.homeManagerModules.impermanence
            inputs.plasma-manager.homeManagerModules.plasma-manager
            inputs.base16.homeManagerModule
            inputs.ags.homeManagerModules.default
            {
              scheme = "${pkgs.theme}/theme.yaml";
              home = { inherit stateVersion; };
            }
            ./modules/home-manager
          ];
        })
      ];
    });
}
