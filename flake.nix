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
    overlays = import ./overlays {inherit inputs;};
    pkgs = libx.forAllPlatforms (
      platform: let
        pkgs = import nixpkgs {
          system = platform;
          config.allowUnfree = true;
          overlays = [
            overlays.additions
            overlays.modifications
            overlays.unstable-packages
            inputs.neovim-nightly-overlay.overlay
            inputs.nixneovimplugins.overlays.default
          ];
        };
      in
        pkgs
    );
  in {
    #######################################
    ############# OVERLAYS ################
    #######################################
    overlays = overlays;

    #######################################
    ############# packages ################
    #######################################
    packages = pkgs;

    #######################################
    ############# FORMATTER ###############
    #######################################
    formatter =
      libx.forAllPlatforms (platform:
        pkgs.${platform}.workspace.format-configuration);

    #######################################
    ############# SHELLS ##################
    #######################################
    devShells = libx.forAllPlatforms (
      platform: {
        default = import ./shells/dotfiles.nix {inherit inputs pkgs platform;};
        ng = import ./shells/ng.nix {inherit inputs pkgs platform;};
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
