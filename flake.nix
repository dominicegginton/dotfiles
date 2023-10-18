{
  description = "Dom's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.url = "github:pegasust/neovim-darwin-overlay/neovim-fix"; # Temporary fix for neovim nightly overlay
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";

    firefox-darwin-overlay.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs =
    { self
    , nixpkgs
    , nix-formatter-pack
    , home-manager
    , neovim-nightly-overlay
    , nixneovimplugins
    , firefox-darwin-overlay
    , ...
    }:

    let
      inherit (self) inputs outputs;
      stateVersion = "23.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in

    {
      formatter = libx.forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            nixpkgs-fmt.enable = true;
          };
        }
      );

      overlays = import ./overlays { inherit inputs; };

      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );

      nixosConfigurations = {
        iso-console = libx.mkHost {
          hostname = "iso-console";
          username = "nixos";
          installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
        };

        latitude-7390 = libx.mkHost {
          hostname = "latitude-7390";
          username = "dom";
          desktop = "sway";
        };
      };

      homeConfigurations = {
        "dom@latitude-7390" = libx.mkHome {
          hostname = "latitude-7390";
          username = "dom";
          desktop = "sway";
        };

        "dom@burbage" = libx.mkHome {
          hostname = "burbage";
          username = "dom";
        };

        "dom.egginton@MCCML44WMD6T" = libx.mkHome {
          hostname = "MCCML44WMD6T";
          username = "dom.egginton";
          desktop = "quartz";
          platform = "x86_64-darwin";
        };
      };
    };
}
