{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11"; # The stable Nixpkgs channel
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # The unstable Nixpkgs channel
    disko.url = "github:nix-community/disko"; # Declarative disk partitioning
    impermanence.url = "github:nix-community/impermanence"; # Modules to help handle persistant state with ephemeral root store
    nixos-hardware.url = "github:nixos/nixos-hardware/master"; # Collection of NixOS modules covering hardware quirks
    srvos.url = "github:nix-community/srvos"; # Nix profiles for servers
    nix-darwin.url = "github:lnl7/nix-darwin"; # Nix modules of darwin
    sops-nix.url = "github:Mic92/sops-nix"; # Atomic secrets management
    home-manager.url = "github:nix-community/home-manager/release-23.11"; # Manage user environment using Nix
    nix-colors.url = "github:misterio77/nix-colors"; # Modules and schemes to for themeing with Nix
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay"; # Neovim nightly builds overlay
    alejandra.url = "github:kamadorueda/alejandra/3.0.0"; # Nix code formatter
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    alejandra,
    ...
  }: let
    inherit (self) inputs outputs;

    # State version.
    # This is used to ensure that the state is compatible with the current version of the configuration.
    # SEE: https://search.nixos.org/options?channel=unstable&show=system.stateVersion&from=0&size=50&sort=relevance&type=packages&query=stateVersion
    stateVersion = "23.11";

    libx = import ./lib {inherit inputs outputs stateVersion;};
    overlays = import ./overlays {inherit inputs;};
    packages = libx.forAllPlatforms (
      platform:
        import nixpkgs {
          system = platform;
          config.allowUnfree = true;
          overlays = [
            overlays.additions
            overlays.modifications
            overlays.unstable-packages
            inputs.neovim-nightly-overlay.overlay
          ];
        }
    );
  in {
    # Overlays.
    overlays = overlays;

    # Packages with overlays applied.
    #
    # - `nix run .#<package>` run a package (locally from flake directory).
    # - `nix run github:dominicegginton/dotfiles#<package>` run a package.
    # - `nix build github:dominicegginton/dotfiles#<package>` build a package.
    # - `nix shell github:dominicegginton/dotfiles#<package>` enter a shell with a package.
    packages = packages;

    # Nix code formatter.
    #
    # - `nix fmt` run the formatter on this workspace (locally from flake directory).
    formatter =
      libx.forAllPlatforms (platform:
        self.packages.${platform}.alejandra);

    # Nix flake templates.
    #
    # - `nix flake new -t github:dominicegginton/dotfiles#<template>` create a new flake from a template.
    templates = {
      minimal = {
        path = ./templates/minimal;
        description = "Minimal boilerplate";
      };
    };

    # NixOS host configurations.
    nixosConfigurations = {
      iso-console = libx.mkNixosConfiguration {
        hostname = "iso-console";
        username = "nixos";
        role = "iso";
        installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
      };

      latitude-7390 = libx.mkNixosConfiguration {
        hostname = "latitude-7390";
        username = "dom";
        role = "workstation";
        desktop = "sway";
      };
    };

    # NixDarwin host configurations.
    darwinConfigurations = {
      MCCML44WMD6T = libx.mkDarwinConfiguration {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
      };
    };

    # Home configurations.
    homeConfigurations = {
      "dom@latitude-7390" = libx.mkHomeConfiguration {
        hostname = "latitude-7390";
        username = "dom";
        desktop = "sway";
      };
      "dom@burbage" = libx.mkHomeConfiguration {
        hostname = "burbage";
        username = "dom";
      };
      "dom.egginton@MCCML44WMD6T" = libx.mkHomeConfiguration {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
        platform = "x86_64-darwin";
      };
    };

    # Dev shells.
    #
    # - `nix develop` enter the default development shell for this workspace (locally from flake directory).
    # - `nix develop .#<shell>` enter a development shell (locally from flake directory).
    # - `nix develop github:dominicegginton/dotfiles#<shell>` enter a development shell.
    devShells = libx.forAllPlatforms (
      platform: let
        pkgs = self.packages.${platform};
        baseDevPkgs = with pkgs; [
          git
          gitAndTools.git-crypt
          gitAndTools.git-lfs
          gh
        ];

        workspace = import ./shells/workspace.nix {
          inherit
            inputs
            pkgs
            baseDevPkgs
            platform
            ;
        };
      in {
        inherit workspace;

        default = workspace;
        web = import ./shells/web.nix {
          inherit
            inputs
            pkgs
            baseDevPkgs
            platform
            ;
        };
        python = import ./shells/python.nix {
          inherit
            inputs
            pkgs
            baseDevPkgs
            platform
            ;
        };
      }
    );
  };
}
