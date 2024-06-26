# github:dominicegginton/dotfiles
# there's no place like ~/

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    srvos.url = "github:nix-community/srvos";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-darwin.url = "github:lnl7/nix-darwin";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes.url = "github:tinted-theming/schemes";
    tt-schemes.flake = false;
    base16-vim.url = "github:tinted-theming/base16-vim";
    base16-vim.flake = false;
    nur.url = "github:nix-community/nur";
    twm.url = "github:vinnymeller/twm";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    todo.url = "github:dominicegginton/todo";
    nsm.url = "github:dominicegginton/nsm";
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , flake-utils
    , ...
    }:

    let
      inherit (self) inputs outputs;

      # state version
      # see: https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      # see: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/misc/version.nix
      stateVersion = "24.05";

      # my lib and overlays
      myLib = import ./lib.nix { inherit inputs outputs stateVersion; };
      myOverlays = import ./overlays.nix { inherit inputs myLib; };
    in

    with myLib;
    with flake-utils.lib;

    {
      # overlays consumed by other flakes
      overlays = myOverlays;

      # templates used by `nix flake init -t <flake>#<template>`
      templates = import ./templates { };

      # configurations for nixos hosts
      # used by `nixos-rebuild switch --flake <flake>#<hostname>`
      nixosConfigurations = {
        latitude-7390 = mkNixosHost { hostname = "latitude-7390"; };
        ghost-gs60 = mkNixosHost { hostname = "ghost-gs60"; };
        burbage = mkNixosHost { hostname = "burbage"; };
      };

      # configurations for darwin hosts
      # used by `nixos-rebuild switch --flake <flake>#<hostname>`
      darwinConfigurations = {
        MCCML44WMD6T = mkDarwinHost {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
        };
      };

      # home configurations for users available across hosts
      # used by `home-manager switch --flake <flake>`
      homeConfigurations = {
        "dom@latitude-7390" = mkHome {
          hostname = "latitude-7390";
          username = "dom";
          desktop = "sway";
        };
        "dom@ghost-gs60" = mkHome {
          hostname = "ghost-gs60";
          username = "dom";
          desktop = "gamescope";
        };
        "dom@burbage" = mkHome {
          hostname = "burbage";
          username = "dom";
        };
        "dom.egginton@MCCML44WMD6T" = mkHome {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
          platform = "x86_64-darwin";
        };
      };
    }

    //

    eachDefaultSystem
      (system:

      let
        # nixpkgs with configuration and overlays
        pkgs = import nixpkgs {
          inherit system;
          hostPlatform = system;
          config = {
            joypixels.acceptLicense = true;
            nvidia.acceptLicense = true;
            allowUnfree = true;
            # TODO: short this out
            permittedInsecurePackages = [ "nix-2.15.3" ];
          };
          overlays = with myOverlays; [
            additions
            modifications
            unstable-packages
            # the nur does not check the repository for malicious content
            # check all expressions before installing them
            nur.overlay
          ];
        };

        inherit (pkgs) callPackage;
      in

      {
        # formatter for this flake
        formatter = pkgs.nixpkgs-fmt;

        # packages to be exercuted by `nix build <flake>#<name>`
        # or consumed by other flakes
        packages = pkgs;

        # development shells used by `nix develop <flake>#<name>`
        devShells = {
          python = callPackage ./shells/python.nix { };
          web = callPackage ./shells/web.nix { };
          rust = callPackage ./shells/rust.nix { };
          default = callPackage ./shell.nix { };
        };
      });
}
