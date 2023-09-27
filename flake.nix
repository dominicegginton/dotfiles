{
  description = "Dom's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Temporary fix for neovim nightly overlay
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.url = "github:pegasust/neovim-darwin-overlay/neovim-fix";
    firefox-darwin-overlay.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    neovim-nightly-overlay,
    firefox-darwin-overlay,
    ...
  } @inputs:
  let
    stateVersion = "22.11";
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

    nixosConfigurations = {
      latitude-7390 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/latitude-7390/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];

            home-manager.users.dom = ({ config, pkgs, ... }: {
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
            });
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
              firefox-darwin-overlay.overlay
            ];
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnfreePredicate = (_: true);
            programs.home-manager.enable = true;

            home.username = "dom.egginton";
            home.homeDirectory = "/Users/dom.egginton";

            imports = [
              ./users/dom.nix
              ./modules/darwin-applications.nix
            ];

            home.stateVersion = stateVersion;
          }
        ];
      };
    };
  };
}
