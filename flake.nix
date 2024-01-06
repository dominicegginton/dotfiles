{
  inputs = {
    #######################################
    ############# NIXOS PKGS ##############
    #######################################
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #######################################
    ############### MODULES ###############
    #######################################
    srvos.url = "github:nix-community/srvos";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:dominicegginton/nixos-hardware/master";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim/nixos-23.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    #######################################
    ############### OVERLAYS ##############
    #######################################
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    alejandra,
    ...
  }: let
    inherit (self) inputs outputs;
    stateVersion = "23.11";
    libx = import ./lib {inherit inputs outputs stateVersion;};
  in {
    #######################################
    ############# FORMATTER ###############
    #######################################

    # Execute `nix fmt` to format this
    # configuration.
    formatter = libx.forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.writeShellApplication {
          name = "format-workspace";
          runtimeInputs = with pkgs; [
            alejandra.defaultPackage.${system}
            nodePackages.prettier
          ];

          text = ''
            alejandra ./
            prettier --write README.md
          '';
        }
    );

    #######################################
    ############# OVERLAYS ################
    #######################################
    overlays = import ./overlays {inherit inputs;};

    #######################################
    ############ PACKAGES #################
    #######################################
    packages = libx.forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs;}
    );

    #######################################
    ############# MODULES #################
    #######################################
    modules = libx.forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./modules {inherit pkgs;}
    );

    #######################################
    ############# SHELLS ##################
    #######################################
    devShells = libx.forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.unstable-packages
          ];
        };
      in {
        default = pkgs.mkShell rec {
          inherit
            (inputs.sops-nix.packages."${system}")
            sops-import-keys-hook
            ssh-to-pgp
            sops-init-gpg-key
            ;
          NIX_CONFIG = "experimental-features = nix-command flakes";
          sopsPGPKeyDirs = ["./secrets/keys"];
          nativeBuildInputs = with pkgs; [
            nix
            home-manager
            ssh-to-pgp
            sops
            sops-import-keys-hook
            ssh-to-pgp
            sops-init-gpg-key
            workspace.rebuild-host
            workspace.rebuild-home
            workspace.rebuild-configuration
            workspace.upgrade-configuration
            workspace.rebuild-iso-console
            workspace.gpg-import-keys
          ];
        };
      }
    );

    #######################################
    ############# HOSTS ###################
    #######################################
    nixosConfigurations.iso-console = libx.mkNixosConfiguration {
      hostname = "iso-console";
      username = "nixos";
      installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
    };
    nixosConfigurations.latitude-7390 = libx.mkNixosConfiguration {
      hostname = "latitude-7390";
      username = "dom";
      desktop = "sway";
    };
    darwinConfigurations.MCCML44WMD6T = libx.mkDarwinConfiguration {
      hostname = "MCCML44WMD6T";
      username = "dom.egginton";
    };

    #######################################
    ######## HOME CONFIGURATIONS ##########
    #######################################
    homeConfigurations."dom@latitude-7390" = libx.mkHomeConfiguration {
      hostname = "latitude-7390";
      username = "dom";
      desktop = "sway";
    };
    homeConfigurations."dom@burbage" = libx.mkHomeConfiguration {
      hostname = "burbage";
      username = "dom";
    };
    homeConfigurations."dom.egginton@MCCML44WMD6T" = libx.mkHomeConfiguration {
      hostname = "MCCML44WMD6T";
      username = "dom.egginton";
      desktop = "quartz";
      platform = "x86_64-darwin";
    };
  };
}
