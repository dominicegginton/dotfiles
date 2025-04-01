{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-images.url = "github:nix-community/nixos-images";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vulnix.url = "github:nix-community/vulnix";
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes.url = "github:tinted-theming/schemes";
    tt-schemes.flake = false;
    base16-vim.url = "github:tinted-theming/base16-vim";
    base16-vim.flake = false;
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    twm.url = "github:vinnymeller/twm";
    twm.inputs.nixpkgs.follows = "nixpkgs";
    todo.url = "github:dominicegginton/todo";
    todo.inputs.nixpkgs.follows = "nixpkgs";
    flip.url = "github:dominicegginton/flip";
    flip.inputs.nixpkgs.follows = "nixpkgs";
    roll.url = "github:dominicegginton/roll";
    roll.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  outputs = { self, nixpkgs, flake-utils, ... }:

    let
      inherit (self) inputs outputs;
      stateVersion = "24.05";
      theme = "dark";
      tailnet = "soay-puffin.ts.net";
      lib = import ./lib.nix { inherit inputs outputs stateVersion theme tailnet; };
      overlays = import ./overlays.nix { inherit inputs lib; };
      templates = import ./templates { };
    in

    with lib;
    with flake-utils.lib;

    eachDefaultSystem
      (system:

        let
          pkgs = import nixpkgs {
            inherit system;
            hostPlatform = system;
            config = {
              joypixels.acceptLicense = true;
              nvidia.acceptLicense = true;
              allowUnfree = true;
              allowBroken = true;
            };
            overlays = with inputs; [
              overlays.default
              overlays.unstable
              flip.overlays.default
              roll.overlays.default
              nix-topology.overlays.default
              nix-topology.overlays.topology
            ];
          };
        in

        {
          formatter = pkgs.nixpkgs-fmt;
          legacyPackages = pkgs;
          devShells = {
            default = pkgs.callPackage ./shell.nix { };
            nodejs = pkgs.callPackage ./shells/nodejs.nix { };
            python = pkgs.callPackage ./shells/python.nix { };
          };
          topology = import inputs.nix-topology {
            inherit pkgs;
            modules = [
              ./topology.nix
              { inherit (self) nixosConfigurations; }
            ];
          };
        })

    //

    {
      inherit overlays templates;

      nixosConfigurations = {
        ghost-gs60 = mkNixosHost { hostname = "ghost-gs60"; };
        latitude-5290 = mkNixosHost { hostname = "latitude-5290"; };
        latitude-7390 = mkNixosHost { hostname = "latitude-7390"; };
        nixos-installer = mkNixosHost { hostname = "nixos-installer"; };
      };

      darwinConfigurations = {
        MCCML44WMD6T = mkDarwinHost { hostname = "MCCML44WMD6T"; };
      };
    };
}
