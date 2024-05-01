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
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland"; # Bleading edge wayland packages
    alejandra.url = "github:kamadorueda/alejandra/3.0.0"; # Nix code formatter
    todo.url = "github:dominicegginton/todo"; # Suckless todo manager
    nsm.url = "github:dominicegginton/nsm"; # Nix system manager
    nix-index-database.url = "github:nix-community/nix-index-database"; # Nix index database
  };

  outputs = {
    self,
    nixpkgs,
    alejandra,
    todo,
    ...
  }: let
    inherit (self) inputs outputs;

    stateVersion = "23.11";
    libx = import ./lib {inherit inputs outputs stateVersion;};
    overlays = import ./overlays {inherit inputs;};
    templates = import ./templates {};
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
            # inputs.nsm.overlays.default
            # inputs.nixpkgs-wayland.overlay
          ];
        }
    );
  in {
    overlays = overlays;
    packages = pkgs;
    templates = templates;
    formatter =
      libx.forAllPlatforms (platform:
        self.packages.${platform}.alejandra);

    devShells = libx.forAllPlatforms (
      platform: let
        pkgs = self.packages.${platform};
      in
        import ./shells {inherit inputs pkgs platform;}
    );

    nixosConfigurations.iso-console = libx.mkNixosConfiguration {
      hostname = "iso-console";
      username = "nixos";
      role = "iso";
      installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
    };

    nixosConfigurations.latitude-7390 = libx.mkNixosConfiguration {
      hostname = "latitude-7390";
      username = "dom";
      role = "workstation";
      desktop = "sway";
    };

    nixosConfigurations.ghost-gs60 = libx.mkNixosConfiguration {
      hostname = "ghost-gs60";
      username = "dom";
      role = "gamestation";
      desktop = "gamescope";
    };

    darwinConfigurations = {
      MCCML44WMD6T = libx.mkDarwinConfiguration {
        hostname = "MCCML44WMD6T";
        username = "dom.egginton";
      };
    };

    homeConfigurations."dom@latitude-7390" = libx.mkHomeConfiguration {
      hostname = "latitude-7390";
      username = "dom";
      desktop = "sway";
    };

    homeConfigurations."dom@ghost-gs60" = libx.mkHomeConfiguration {
      hostname = "ghost-gs60";
      username = "dom";
      desktop = "gamescope";
    };

    homeConfigurations."dom@burbage" = libx.mkHomeConfiguration {
      hostname = "burbage";
      username = "dom";
    };

    homeConfigurations."dom.egginton@MCCML44WMD6T" = libx.mkHomeConfiguration {
      hostname = "MCCML44WMD6T";
      username = "dom.egginton";
      platform = "x86_64-darwin";
    };
  };
}
