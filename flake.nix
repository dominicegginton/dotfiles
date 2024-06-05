{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    srvos.url = "github:nix-community/srvos";
    nix-darwin.url = "github:lnl7/nix-darwin";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    nix-colors.url = "github:misterio77/nix-colors";
    twm.url = "github:vinnymeller/twm";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    todo.url = "github:dominicegginton/todo";
    nsm.url = "github:dominicegginton/nsm";
    nix-index-database.url = "github:nix-community/nix-index-database";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (self) inputs outputs;
    stateVersion = "23.11";
    libx = import ./lib {inherit inputs outputs stateVersion;};
    overlays = import ./overlays {inherit inputs;};
    templates = import ./templates {};
    pkgs = libx.forSystems (
      system: let
        hostPlatform = system;
        config = {
          joypixels.acceptLicense = true;
          nvidia.acceptLicense = true;
          allowUnfree = true;
          permittedInsecurePackages = ["nix-2.15.3"];
        };
      in
        import nixpkgs {
          inherit system hostPlatform config;
          overlays = [
            overlays.additions
            overlays.modifications
            overlays.unstable-packages
          ];
        }
    );
  in {
    inherit templates overlays;

    packages = pkgs;
    formatter = libx.forSystems (system: pkgs.${system}.alejandra);

    devShells = libx.forSystems (system: let
      pkgs = self.packages.${system};
    in {
      python = import ./shells/python.nix {inherit pkgs;};
      web = import ./shells/web.nix {inherit pkgs;};
      rust = import ./shells/rust.nix {inherit pkgs;};
      default = import ./shell.nix {inherit pkgs;};
    });

    nixosConfigurations = {
      latitude-7390 = libx.mkNixosHost {hostname = "latitude-7390";};
      ghost-gs60 = libx.mkNixosHost {hostname = "ghost-gs60";};
      burbage = libx.mkNixosHost {hostname = "burbage";};
    };

    darwinConfigurations = {
      MCCML44WMD6T = libx.mkDarwinHost {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
      };
    };

    homeConfigurations = {
      "dom@latitude-7390" = libx.mkHome {
        hostname = "latitude-7390";
        username = "dom";
        desktop = "sway";
      };

      "dom@ghost-gs60" = libx.mkHome {
        hostname = "ghost-gs60";
        username = "dom";
        desktop = "gamescope";
      };

      "dom@burbage" = libx.mkHome {
        hostname = "burbage";
        username = "dom";
      };

      "dom.egginton@MCCML44WMD6T" = libx.mkHome {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
        platform = "x86_64-darwin";
      };
    };
  };
}
