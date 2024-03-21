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
    todo.url = "github:dominicegginton/todo"; # Suckless todo manager
    nix-index-database.url = "github:nix-community/nix-index-database"; # Nix index database
    nix-alien.url = "github:thiagokokada/nix-alien"; # Run unpatched binaries on Nix/NixOS
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    alejandra,
    todo,
    ...
  }: let
    inherit (self) inputs outputs;

    # State version.
    # This is used to ensure that the state is compatible with the current version of the configuration.
    # SEE: https://search.nixos.org/options?channel=unstable&show=system.stateVersion&from=0&size=50&sort=relevance&type=packages&query=stateVersion
    stateVersion = "23.11";

    # Internal Nix functions.
    libx = import ./lib {inherit inputs outputs stateVersion;};

    # Workspace overlays.
    overlays = import ./overlays {inherit inputs;};

    # Workspace packages.
    # These are the packages that are available in this workspace.
    # Worksapce overlays are applied to these packages.
    pkgs = libx.forAllPlatforms (
      platform:
        import nixpkgs {
          system = platform;
          hostPlatform = platform;
          config.allowUnfree = true;
          config.permittedInsecurePackages = ["nix-2.15.3"];
          overlays = [
            overlays.additions
            overlays.modifications
            overlays.unstable-packages
            inputs.neovim-nightly-overlay.overlay
            inputs.todo.overlays.default
            inputs.nix-alien.overlays.default
          ];
        }
    );

    pkgs-unstable = libx.forAllPlatforms (
      platform:
        import nixpkgs-unstable {
          system = platform;
          hostPlatform = platform;
          overlays = [
            overlays.additions
            overlays.modifications
            overlays.unstable-packages
          ];
        }
    );

    templates = import ./templates {};
  in {
    # Worksapce overlays.
    overlays = overlays;

    # Workspace packages.
    # These packages are available in this workspace.
    # Workspace overlays are applied to these packages.
    #
    # Usegae: `nix run .#<package>` or `nix run github:dominicegginton/dotfiles#<package>`
    packages = pkgs;

    # Nix flake templates.
    # These templates are available via this workspace flake.
    #
    # Usegae: `nix flake init -t github:dominicegginton/dotfiles#<template>`
    templates = templates;

    # NixOS host configurations.
    # Avaiable NixOS host configurations.
    #
    # Usage:
    # `nixos-rebuild build --flake .#<configuration>` build the configuration
    # `nixos-rebuild test --flake .#<configuration>` build and activate the configuration
    # `nixos-rebuild boot --flake .#<configuration>` build the configuration, make it the default boot grub entry but do not activate it
    # `nixos-rebuild switch --flake .#<configuration>` build the configuration, make it the default boot grub entry and activate it
    # `nixos-rebuild build-vm --flake .#<configuration>` build the configuration as a virtual machine
    nixosConfigurations = {
      # ISO Console.
      # Used for installing NixOS.
      iso-console = libx.mkNixosConfiguration {
        hostname = "iso-console";
        username = "nixos";
        role = "iso";
        installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
      };

      # Latitude 7390.
      # Personal workstation.
      latitude-7390 = libx.mkNixosConfiguration {
        hostname = "latitude-7390";
        username = "dom";
        role = "workstation";
        desktop = "sway";
      };
    };

    # NixDarwin host configurations.
    # Avaiable NixDarwin host configurations.
    #
    # Usage:
    # `darwin-rebuild build --flake .#<configuration>` build the configuration
    # `darwin-rebuild test --flake .#<configuration>` build and activate the configuration
    # `darwin-rebuild switch --flake .#<configuration>` build the configuration and activate it
    darwinConfigurations = {
      # MCCML44WMD6T.
      # Work provided system.
      MCCML44WMD6T = libx.mkDarwinConfiguration {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
      };
    };

    # Home configurations.
    # Avaiable home configurations.
    #
    # Usage:
    # `home-manager switch --flake .#<configuration>` build the configuration and activate it
    homeConfigurations = {
      # dom#latitude-7390.
      # Personal user account configuration for latitude-7390.
      "dom@latitude-7390" = libx.mkHomeConfiguration {
        hostname = "latitude-7390";
        username = "dom";
        desktop = "sway";
      };

      # dom#burbage.
      # Personal user account configuration for burbage.
      "dom@burbage" = libx.mkHomeConfiguration {
        hostname = "burbage";
        username = "dom";
      };

      # dom.egginton#MCCML44WMD6T.
      # Work managed user account configuration for MCCML44WMD6T.
      "dom.egginton@MCCML44WMD6T" = libx.mkHomeConfiguration {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
        platform = "x86_64-darwin";
      };
    };

    # Workspace formatter.
    # Formats the worksapce using the `alejandra` package.
    #
    # Usage: `nix fmt`
    formatter =
      libx.forAllPlatforms (platform:
        self.packages.${platform}.alejandra);

    # Dev shells.
    # Avaiable development shells.
    #
    # Usage: `nix develop github:dominicegginton/dotfiles#<shell>`
    devShells = libx.forAllPlatforms (
      platform: let
        # Packages.
        # All the packages that are available in this workspace
        # for the current platform.
        pkgs = self.packages.${platform};
      in
        import ./shells {inherit inputs pkgs platform;}
    );
  };
}
