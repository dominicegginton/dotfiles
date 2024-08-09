# github:dominicegginton/dotfiles
# there's no place like ~/

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-schemas.url = "github:determinatesystems/flake-schemas";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    base16.url = "github:SenchoPens/base16.nix";
    nix-index-database.url = "github:nix-community/nix-index-database";
    tt-schemes.url = "github:tinted-theming/schemes";
    tt-schemes.flake = false;
    base16-vim.url = "github:tinted-theming/base16-vim";
    base16-vim.flake = false;
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    nur.url = "github:nix-community/nur";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    twm.url = "github:vinnymeller/twm";
    twm.inputs.nixpkgs.follows = "nixpkgs";
    todo.url = "github:dominicegginton/todo";
    todo.inputs.nixpkgs.follows = "nixpkgs";
    nsm.url = "github:dominicegginton/nsm";
    nsm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, flake-schemas, nur, ... }:

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
              default
              additions
              modifications
              unstable-packages
              nur.overlay
            ];
          };
        in

        {
          formatter = pkgs.nixpkgs-fmt;
          packages = pkgs;
          devShells = {
            default = pkgs.callPackage ./shell.nix { };
            nodejs = pkgs.callPackage ./shells/web.nix { };
            python = pkgs.callPackage ./shells/python.nix { };
          };
        })

    //

    {
      inherit overlays templates;

      schemas = flake-schemas.schemas;

      nixosConfigurations = {
        latitude-7390 = mkNixosHost { hostname = "latitude-7390"; };
        ghost-gs60 = mkNixosHost { hostname = "ghost-gs60"; };
        burbage = mkNixosHost { hostname = "burbage"; };
      };

      darwinConfigurations = {
        MCCML44WMD6T = mkDarwinHost {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
        };
      };

      homeConfigurations = {
        "dom@latitude-7390" = mkHome {
          hostname = "latitude-7390";
          username = "dom";
        };
        "dom@ghost-gs60" = mkHome {
          hostname = "ghost-gs60";
          username = "dom";
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
    };
}
