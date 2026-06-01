{
  # External flake inputs
  inputs = {
    # Core NixOS and Nixpkgs source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Collection of NixOS modules for common hardware devices
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Integration for running NixOS as a WSL2 distribution
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Community-maintained collection of various NixOS images
    nixos-images.url = "github:nix-community/nixos-images";

    # Declarative configuration and state management for user environments
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative disk partitioning, formatting, and mounting tools
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Tools for managing persistent files on ephemeral/impermanent root filesystems
    impermanence.url = "github:nix-community/impermanence";

    # USB user session native systemd deadmans kill switch for emergency system lockdown
    deadman.url = "github:dominicegginton/deadman";
    deadman.inputs.nixpkgs.follows = "nixpkgs";

    # Dit0 is a tailnet native LDAP directory server for managing users, groups, and devices in a Tailscale network
    dit0.url = "github:dominicegginton/dit0";
    dit0.inputs.nixpkgs.follows = "nixpkgs";

    # Generate network and infrastructure topology diagrams from NixOS configurations
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";

    # Generate matrix configurations for GitHub Actions workflows
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

    # Compatibility shim for run0 to support legacy sudo-style commands
    run0-sudo-shim.url = "github:lordgrimmauld/run0-sudo-shim";
    run0-sudo-shim.inputs.nixpkgs.follows = "nixpkgs";

    # Theming system following the Base16 architecture
    base16.url = "github:SenchoPens/base16.nix";

    # Secret management with SOPS
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # tsnsrv is a reverse proxy on your tailnet
    tsnsrv.url = "github:boinkor-net/tsnsrv";
    tsnsrv.inputs.nixpkgs.follows = "nixpkgs";

    # Niri flake for latest features and modules
    niri.url = "github:niri-wm/niri";

    # Hermes Agent is a community-driven, locally-controlled AI agent
    hermes-agent.url = "github:NousResearch/hermes-agent";
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
      home-manager,
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

      # List of unfree packages allowed in the system
      unfreePackages = [
        "YouTube_full_color_icon_2017.svg"
        "bws"
        "gateway"
        "github-copilot-cli"
        "google-chrome"
        "open-webui"
        "vscode"
        "vscode-extension-github-copilot"
        "vscode-with-extensions"
        "youtube-tv"
      ];

      # Configured nixpkgs instances for each system
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config = {
            # Allow specific unfree packages
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
          };
          # Apply system-wide overlays
          overlays = with self.inputs; [
            deadman.overlays.default
            dit0.overlays.default
            nix-topology.overlays.default
            nix-topology.overlays.topology
            run0-sudo-shim.overlays.default
            self.outputs.overlays.default
            self.outputs.overlays.withSbom
          ];
        }
      );

      githubPlatforms = lib.attrNames nix-github-actions.lib.githubPlatforms;

      # Systems supported by both this flake and GitHub Actions
      githubPlatformsForSystems = lib.intersectLists systems githubPlatforms;
    in

    {
      # Auto-formatter for all nix files in the repository
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-tree);

      # Custom library functions
      lib = import ./lib.nix { inherit self; };

      # Standalone home-manager configurations
      homeConfigurations = {
        dom = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.x86_64-linux;
          modules = [ ./home/dom/default.nix ];
          extraSpecialArgs = {
            inherit self;
            username = "dom";
          };
        };
      };

      # Custom package overlays
      overlays = import ./overlays.nix { inherit self; };

      # GitHub Actions workflow matrix generation
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks = lib.getAttrs githubPlatformsForSystems self.outputs.devShells;
      };

      # Continuous integration checks
      checks = forAllSystems (system: {
        # Check that the flake and its outputs are valid
        formatter = self.outputs.formatter.${system};
      });

      # Legacy packages for backward compatibility
      legacyPackages = nixpkgsFor;

      # System-specific packages (like network topology and ISO images)
      packages = forAllSystems (
        system:
        {
          # Network topology diagram
          topology =
            (import self.inputs.nix-topology {
              pkgs = nixpkgsFor.${system};
              modules = [
                ./topology.nix
                { nixosConfigurations = self.outputs.nixosConfigurations; }
              ];
            }).config.output;
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          # Custom live installer ISO (infector)
          # Only buildable on x86_64-linux by default
          infector-iso = self.nixosConfigurations.infector.config.system.build.isoImage;
        }
      );

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

      # NixOS host configurations
      nixosConfigurations = {
        # MSI GS60 Ghost Laptop
        ghost-gs60 = self.outputs.lib.nixosSystem { hostname = "ghost-gs60"; };

        # Dell Latitude 7390 Laptop
        latitude-7390 = self.outputs.lib.nixosSystem { hostname = "latitude-7390"; };

        # Custom unattended installation media (Live ISO)
        infector = self.outputs.lib.nixosSystem {
          hostname = "infector";
          user = null;
        };

        # Windows Subsystem for Linux environment
        wsl = self.outputs.lib.nixosSystem { hostname = "wsl"; };
      };
    };
}
