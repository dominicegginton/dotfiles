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

      lib = import ./lib.nix {
        inherit inputs outputs;

        stateVersion = "23.11";
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        overlays = import ./overlays.nix {
          inherit inputs;
        };
        templates = import ./templates { };

        pkgs = import nixpkgs {
          inherit system;

          hostPlatform = system;

          config = {
            joypixels.acceptLicense = true;
            nvidia.acceptLicense = true;
            allowUnfree = true;
            permittedInsecurePackages = [ "nix-2.15.3" ];
          };

          overlays = with overlays; [
            additions
            modifications
            unstable-packages
          ];
        };
      in
      {
        packages = pkgs;
        formatter = pkgs.nixpkgs-fmt;

        devShells = {
          python = import ./shells/python.nix { inherit pkgs; };
          web = import ./shells/web.nix { inherit pkgs; };
          rust = import ./shells/rust.nix { inherit pkgs; };
          default = import ./shell.nix { inherit pkgs; };
        };
      })
    //
    {
      templates = import ./templates { };

      nixosConfigurations = {
        latitude-7390 = lib.mkNixosHost {
          hostname = "latitude-7390";
        };

        ghost-gs60 = lib.mkNixosHost {
          hostname = "ghost-gs60";
        };

        burbage = lib.mkNixosHost {
          hostname = "burbage";
        };
      };

      darwinConfigurations = {
        MCCML44WMD6T = lib.mkDarwinHost {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
        };
      };

      homeConfigurations = {
        "dom@latitude-7390" = lib.mkHome {
          hostname = "latitude-7390";
          username = "dom";
          desktop = "sway";
        };

        "dom@ghost-gs60" = lib.mkHome {
          hostname = "ghost-gs60";
          username = "dom";
          desktop = "gamescope";
        };

        "dom@burbage" = lib.mkHome {
          hostname = "burbage";
          username = "dom";
        };

        "dom.egginton@MCCML44WMD6T" = lib.mkHome {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
          platform = "x86_64-darwin";
        };
      };
    };
}
