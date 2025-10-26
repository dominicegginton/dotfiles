{ inputs, outputs, nixConfig }:

let
  tailnet = "soay-puffin.ts.net";
  stateVersion.darwin = 5;
  specialArgsFor = { hostname }: {
    inherit inputs outputs tailnet hostname stateVersion nixConfig;
    dlib = outputs.lib;
  };
in

rec {
  inherit tailnet;
  nixosHostnames = inputs.nixpkgs.lib.attrNames outputs.nixosConfigurations;
  darwinHostnames = inputs.nixpkgs.lib.attrNames outputs.darwinConfigurations;
  hostnames = nixosHostnames ++ darwinHostnames;
  maintainers = inputs.nixpkgs.lib.maintainers // {
    dominicegginton = {
      name = "Dominic Egginton";
      email = "dominic.egginton@gmail.com";
      github = "dominicegginton";
      githubId = 28626241;
      sshKeys = [ "ssh-rsa4096/4C79CE4F82847A9F" ];
    };
  };
  eachPlatformMerge = op: platforms: f: builtins.foldl' (op f) { } (if !builtins ? currentSystem || builtins.elem builtins.currentSystem platforms then platforms else platforms ++ [ builtins.currentSystem ]);
  eachPlatform = eachPlatformMerge (f: attrs: platform: let ret = f platform; in builtins.foldl' (attrs: key: attrs // { ${key} = (attrs.${key} or { }) // { ${platform} = ret.${key}; }; }) attrs (builtins.attrNames ret));
  packagesFrom = module: platform: module.packages.${platform};
  nixosSystem = { hostname, platform ? "x86_64-linux", extraModules ? [ ], ... }:
    inputs.nixpkgs.lib.nixosSystem rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = specialArgsFor { inherit hostname; };
      modules = [
        inputs.base16.nixosModule
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.default
        inputs.nix-topology.nixosModules.default
        ./modules/nixos
        ./hosts/nixos/${hostname}.nix
      ] ++ extraModules;
    };
  darwinSystem = { hostname, platform ? "x86_64-darwin", extraModules ? [ ], ... }:
    inputs.nix-darwin.lib.darwinSystem rec {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = specialArgsFor { inherit hostname; };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        ./modules/darwin
        ./hosts/darwin/${hostname}.nix
        ({ pkgs, ... }: {
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.sharedModules = [
            inputs.impermanence.homeManagerModules.impermanence
            inputs.base16.homeManagerModule
            inputs.ags.homeManagerModules.default
            {
              scheme = "${pkgs.theme}/resodence-theme.yaml";
              home = { stateVersion = stateVersion.darwin; };
            }
            ./modules/home-manager
          ];
        })
      ] ++ extraModules;
    };
}
