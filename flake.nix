{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly-overlay,  ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

    nixosConfigurations = {
      latitude-7390 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./machines/latitude-7390/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [ 
              neovim-nightly-overlay.overlay
            ];
          }
        ];
      };
    };

    homeConfigurations = {
      "dominic.egginton@MCCML44WMD6T" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}
