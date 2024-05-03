{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    srvos.url = "github:nix-community/srvos";
    nix-darwin.url = "github:lnl7/nix-darwin";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    nix-colors.url = "github:misterio77/nix-colors";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    todo.url = "github:dominicegginton/todo";
    nsm.url = "github:dominicegginton/nsm";
    nix-index-database.url = "github:nix-community/nix-index-database";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    todo,
    ...
  }: let
    inherit (self) inputs outputs;
    stateVersion = "23.11";
    libx = import ./lib {inherit inputs outputs stateVersion;};
    overlays = import ./overlays {inherit inputs;};
    templates = import ./templates {};
    shells = import ./shells {};
    pkgs = libx.forSystems (
      system:
        import nixpkgs {
          inherit system;
          hostPlatform = system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = ["nix-2.15.3"];
          overlays = [
            overlays.additions
            overlays.modifications
            overlays.unstable-packages
            inputs.neovim-nightly-overlay.overlay
            inputs.todo.overlays.default
          ];
        }
    );
  in {
    inherit templates overlays;
    packages = pkgs;
    formatter = libx.forSystems (system: pkgs.${system}.alejandra);
    devShells = libx.forSystems (system: let
      pkgs = pkgs.${system};
    in {
      python = import ./shells/python.nix {inherit pkgs;};
      web = import ./shells/web.nix {inherit pkgs;};
      rust = import ./shells/rust.nix {inherit pkgs;};
      default = import ./shell.nix {inherit inputs pkgs system;};
    });
    nixosConfigurations.latitude-7390 = libx.mkNixosHost rec {hostname = "latitude-7390";};
    nixosConfigurations.ghost-gs60 = libx.mkNisosHost rec {hostname = "ghost-gs60";};
    nixosConfigurations.burbage = libx.mkNixosHost rec {hostname = "burbage";};
    nixosConfigurations.iso-console = libx.mkNixosHost rec {
      hostname = "iso-console";
      installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
    };
    darwinConfigurations.MCCML44WMD6T = libx.mkDarwinHost rec {
      hostname = "MCCML44WMD6T";
      username = "dom.egginton";
    };
    homeConfigurations."dom@latitude-7390" = libx.mkHome rec {
      hostname = "latitude-7390";
      username = "dom";
      desktop = "sway";
    };
    homeConfigurations."dom@ghost-gs60" = libx.mkHome rec {
      hostname = "ghost-gs60";
      username = "dom";
      desktop = "gamescope";
    };
    homeConfigurations."dom@burbage" = libx.mkHome rec {
      hostname = "burbage";
      username = "dom";
    };
    homeConfigurations."dom.egginton@MCCML44WMD6T" = libx.mkHome rec {
      hostname = "MCCML44WMD6T";
      username = "dom.egginton";
      platform = "x86_64-darwin";
    };
  };
}
