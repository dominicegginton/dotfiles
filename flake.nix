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
    nix-colors.url = "github:misterio77/nix-colors";
    twm.url = "github:vinnymeller/twm";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    todo.url = "github:dominicegginton/todo";
    nsm.url = "github:dominicegginton/nsm";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:

    let
      inherit (self) inputs outputs;

      # state version
      stateVersion = "24.05";

      # my lib and overlays
      myLib = import ./lib.nix { inherit inputs outputs stateVersion; };
      myOverlays = import ./overlays.nix { inherit inputs; };
    in

    with myLib;
    with flake-utils.lib;

    {
      # flake templates
      templates = import ./templates { };

      # configurations for nixos hosts
      nixosConfigurations = {
        latitude-7390 = mkNixosHost { hostname = "latitude-7390"; };
        ghost-gs60 = mkNixosHost { hostname = "ghost-gs60"; };
        burbage = mkNixosHost { hostname = "burbage"; };
      };

      # configurations for darwin hosts
      darwinConfigurations = {
        MCCML44WMD6T = mkDarwinHost {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
        };
      };

      # home configurations for users available across hosts
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
        # nixpkgs
        pkgs = import nixpkgs {
          inherit system;
          hostPlatform = system;
          config = {
            joypixels.acceptLicense = true;
            nvidia.acceptLicense = true;
            allowUnfree = true;
            permittedInsecurePackages = [ "nix-2.15.3" ];
          };
          overlays = with myOverlays; [
            additions
            modifications
            unstable-packages
          ];
        };
      in

      {
        # nixpkgs
        packages = pkgs;

        # formatter for this flake
        formatter = pkgs.nixpkgs-fmt;

        # development shells
        devShells = {
          python = import ./shells/python.nix { inherit pkgs; };
          web = import ./shells/web.nix { inherit pkgs; };
          rust = import ./shells/rust.nix { inherit pkgs; };
          default = import ./shell.nix { inherit pkgs; };
        };
      });
}
