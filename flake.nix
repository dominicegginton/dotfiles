# github:dominicegginton/dotfiles
# there's no place like ~/

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs = { self, nixpkgs, flake-utils, flip, roll, ... }:

    let
      inherit (self) inputs outputs;
      stateVersion = "24.05";
      lib = import ./lib.nix { inherit inputs outputs stateVersion; };
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
            overlays = with overlays; [
              additions
              modifications
              unstable-packages
              flip.overlays.default
              roll.overlays.default
            ];
          };
        in

        {
          formatter = pkgs.nixpkgs-fmt;
          packages = pkgs;
          devShells = {
            default = pkgs.callPackage ./shell.nix { };
            nodejs = pkgs.callPackage ./shells/nodejs.nix { };
            python = pkgs.callPackage ./shells/python.nix { };
            python-notebook = pkgs.callPackage ./shells/python-notebook.nix { };
          };
        })

    //

    {
      inherit overlays templates;

      nixosConfigurations = {
        latitude-5290 = mkNixosHost { hostname = "latitude-5290"; };
        latitude-7390 = mkNixosHost { hostname = "latitude-7390"; };
        ghost-gs60 = mkNixosHost { hostname = "ghost-gs60"; };
        burbage = mkNixosHost { hostname = "burbage"; };
        precision-5530 = mkNixosHost { hostname = "precision-5530"; };
        minimal-iso = mkNixosIso { hostname = "minimal-iso"; };
      };

      darwinConfigurations = {
        MCCML44WMD6T = mkDarwinHost { hostname = "MCCML44WMD6T"; };
      };
    };
}
