rec {
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-images.url = "github:nix-community/nixos-images";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
    deadman.url = "github:dominicegginton/deadman";
    deadman.inputs.nixpkgs.follows = "nixpkgs";
    ags.url = "github:aylur/ags?rev=3ed9737bdbc8fc7a7c7ceef2165c9109f336bff6";
    ags.inputs.nixpkgs.follows = "nixpkgs";
    base16.url = "github:SenchoPens/base16.nix";
    run0-sudo-shim.url = "github:lordgrimmauld/run0-sudo-shim";
    run0-sudo-shim.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:yalter/niri";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    experimental-features = [ "flakes" "nix-command" ];
    builders-use-substitutes = true;
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  outputs = { self, nixpkgs, nix-github-actions, ... }:

    let
      inherit (nixpkgs) lib;

      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;

      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config = nixConfig // {
          allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "vscode"
            "vscode-with-extensions"
            "vscode-extension-github-copilot"
            "bws"
          ];
        };
        overlays = with self.inputs; [
          self.outputs.overlays.default
          niri.overlays.default
          nix-topology.overlays.default
          nix-topology.overlays.topology
          deadman.overlays.default
          run0-sudo-shim.overlays.default
        ];
      });
    in

    {
      inherit nixpkgsFor;

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

      lib = import ./lib.nix { inherit self; };

      overlays = import ./overlays.nix { inherit self; };

      templates = import ./templates { };

      githubActions = with nix-github-actions.lib; mkGithubMatrix { checks = lib.getAttrs (lib.attrNames githubPlatforms) self.outputs.devShells; };

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in {
          default = pkgs.callPackage ./shell.nix { };
          infrastructure = pkgs.callPackage ./infrastructure/shell.nix { };
        });

      topology = forAllSystems (system: import self.inputs.nix-topology {
        pkgs = nixpkgsFor.${system};
        modules = [
          ./topology.nix
          { nixosConfigurations = self.outputs.nixosConfigurations; }
        ];
      });

      nixosConfigurations = {
        latitude-7390 = self.outputs.lib.nixosSystem {
          hostname = "latitude-7390";
          modules = [
            ./hosts/latitude-7390.nix
            ./modules/users/dom.nix
          ];
        };

        installer = self.outputs.lib.nixosSystem {
          hostname = "installer";
          modules = [ ./hosts/installer.nix ];
        };

        bellgrade = self.outputs.lib.nixosSystem {
          hostname = "bellgrade";
          modules = [ ./hosts/bellgrade.nix ];
        };

        walsgrave = self.outputs.lib.nixosSystem {
          hostname = "walsgrave";
          modules = [
            ./hosts/walsgrave.nix
            ./modules/users/dom.nix
          ];
        };
      };
    };
}



