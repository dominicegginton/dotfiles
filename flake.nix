{
  inputs = {
    #######################################
    ############# NIXOS PKGS ##############
    #######################################
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #######################################
    ############### MODULES ###############
    #######################################
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

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
    stateVersion = "23.05";
    libx = import ./lib {inherit inputs outputs stateVersion;};
  in {
    #######################################
    ############# FORMATTER ###############
    #######################################
    formatter = libx.forAllSystems (system: alejandra.defaultPackage.${system});

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
      in
        pkgs.callPackage ./shell.nix {
          inherit pkgs;
          inherit
            (inputs.sops-nix.packages."${system}")
            sops-import-keys-hook
            ssh-to-pgp
            sops-init-gpg-key
            ;
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
