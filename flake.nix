{
  description = "Dom's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Temporary fix for neovim nightly overlay
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.url = "github:pegasust/neovim-darwin-overlay/neovim-fix";
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
    firefox-darwin-overlay.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    neovim-nightly-overlay,
    nixneovimplugins,
    firefox-darwin-overlay,
    ...
  } @inputs:
  let
    stateVersion = "23.05";
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

    overlays.my = import ./packages;

    nixosConfigurations = {
      iso-console = nixpkgs.lib.nixosSystem {
        hostname = "iso-console";
        username = "nixos";
        installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
      };

      latitude-7390 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/latitude-7390/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [
              neovim-nightly-overlay.overlay
              nixneovimplugins.overlays.default
              self.overlays.my
            ];

            home-manager.users.dom = {
              home.username = "dom";
              home.homeDirectory = "/home/dom";

              services.gpg-agent = {
                enable = true;
                defaultCacheTtl = 1800;
                enableSshSupport = true;
              };

              imports = [
                ./users/dom.nix
                ./modules/wayland.nix
              ];

              home.stateVersion = stateVersion;
            };
          }
        ];
      };
    };

    homeConfigurations = {
      WORK = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-darwin";
        modules = [
          {
            nixpkgs.overlays = [
              neovim-nightly-overlay.overlay
              nixneovimplugins.overlays.default
              firefox-darwin-overlay.overlay
              self.overlays.my
            ];
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnfreePredicate = (_: true);
            programs.home-manager.enable = true;

            home.username = "dom.egginton";
            home.homeDirectory = "/Users/dom.egginton";

            imports = [
              ./users/dom.nix
            ];

            home.stateVersion = stateVersion;
          }
        ];
      };
    };
  };
}
