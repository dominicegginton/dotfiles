rec {
  # External flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-images.url = "github:nix-community/nixos-images";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
    deadman.url = "github:dominicegginton/deadman";
    deadman.inputs.nixpkgs.follows = "nixpkgs";
    dit0.url = "github:dominicegginton/dit0";
    dit0.inputs.nixpkgs.follows = "nixpkgs";
    base16.url = "github:SenchoPens/base16.nix";
    run0-sudo-shim.url = "github:lordgrimmauld/run0-sudo-shim";
    run0-sudo-shim.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  # Flake configuration for nix commands
  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    builders-use-substitutes = true;
    # Custom binary caches to speed up builds
    substituters = [
      "https://cache.nixos.org"
      "https://dominicegginton-dotfiles.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "dominicegginton-dotfiles.cachix.org-1:gm9nclRacSnrdXSPqXso3Abg2TTuo3PrGUJFGlhAzDU="
    ];
  };

  # Flake outputs
  outputs =
    {
      self,
      nixpkgs,
      nix-github-actions,
      nixos-wsl,
      ...
    }:

    let
      inherit (nixpkgs) lib;

      # Supported systems for multi-platform outputs
      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;

      # Helper to generate attributes for all systems
      forAllSystems = lib.genAttrs systems;

      # Configured nixpkgs instances for each system
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config = nixConfig // {
            # Allow specific unfree packages
            allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "vscode"
                "vscode-with-extensions"
                "vscode-extension-github-copilot"
                "bws"
                "youtube-tv"
                "google-chrome"
                "YouTube_full_color_icon_2017.svg"
                "github-copilot-cli"
                "open-webui"
                "gateway"
              ];
          };
          # Apply system-wide overlays
          overlays = with self.inputs; [
            self.outputs.overlays.default
            nix-topology.overlays.default
            nix-topology.overlays.topology
            deadman.overlays.default
            dit0.overlays.default
            run0-sudo-shim.overlays.default
          ];
        }
      );

      githubPLatforms = lib.attrNames nix-github-actions.lib.githubPlatforms;

      # Systems supported by both this flake and GitHub Actions
      githubPlatformsForSystems = lib.intersectLists systems githubPLatforms;
    in

    {
      inherit nixpkgsFor;

      # Auto-formatter for all nix files in the repository
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-tree);

      # Custom library functions
      lib = import ./lib.nix { inherit self; };

      # Custom package overlays
      overlays = import ./overlays.nix { inherit self; };

      # GitHub Actions workflow matrix generation
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks = lib.getAttrs githubPlatformsForSystems self.outputs.devShells;
      };

      # Legacy packages for backward compatibility
      legacyPackages = forAllSystems (system: nixpkgsFor.${system});

      # Development shells for various tasks
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.callPackage ./shell.nix { inherit self; };
          infrastructure = pkgs.callPackage ./infrastructure/shell.nix { };
        }
      );

      # Network topology diagram generation
      topology = forAllSystems (
        system:
        import self.inputs.nix-topology {
          pkgs = nixpkgsFor.${system};
          modules = [
            ./topology.nix
            { nixosConfigurations = self.outputs.nixosConfigurations; }
          ];
        }
      );

      # NixOS host configurations
      nixosConfigurations = {
        # MSI GS60 Ghost Laptop
        ghost-gs60 = self.outputs.lib.nixosSystem {
          hostname = "ghost-gs60";
          modules = [
            ./hosts/ghost-gs60.nix
            ./modules/users/dom.nix
          ];
        };

        # Dell Latitude 7390 Laptop
        latitude-7390 = self.outputs.lib.nixosSystem {
          hostname = "latitude-7390";
          modules = [
            ./hosts/latitude-7390.nix
            ./modules/users/dom.nix
          ];
        };

        # Primary server / Infector
        infector = self.outputs.lib.nixosSystem {
          hostname = "infector";
          modules = [ ./hosts/infector.nix ];
        };

        # Windows Subsystem for Linux environment
        wsl = self.outputs.lib.nixosSystem {
          hostname = "wsl";
          modules = [
            ./hosts/wsl.nix
            ./modules/users/dom.nix
          ];
        };
      };
    };
}
