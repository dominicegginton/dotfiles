{
  # External flake inputs
  inputs = {
    # Core NixOS and Nixpkgs source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Collection of NixOS modules for common hardware devices
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    # Integration for running NixOS as a WSL2 distribution
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # Community-maintained collection of various NixOS images
    nixos-images.url = "github:nix-community/nixos-images";

    # Declarative configuration and state management for user environments
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning, formatting, and mounting tools
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tools for managing persistent files on ephemeral/impermanent root filesystems
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Amber package from the dotfiles maintainer's flake collection
    amber = {
      url = "github:dominicegginton/amber";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generate network and infrastructure topology diagrams from NixOS configurations
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generate matrix configurations for GitHub Actions workflows
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Compatibility shim for run0 to support legacy sudo-style commands
    run0-sudo-shim = {
      url = "github:lordgrimmauld/run0-sudo-shim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Terranix for Nix-based OpenTofu/Terraform infrastructure management
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming system following the Base16 architecture
    base16.url = "github:SenchoPens/base16.nix";

    # Secret management with SOPS
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # tsnsrv is a reverse proxy on your tailnet
    tsnsrv = {
      url = "github:boinkor-net/tsnsrv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri flake for latest features and modules
    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DriftWM — a trackpad-first infinite canvas Wayland compositor
    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Jovian-NixOS for Steam Deck and handheld gaming hardware support
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Seamless git hooks integration
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Velvet — a TV-first Wayland compositor and OS shell
    # velvet = {
    #   url = "git+https://github.com/dominicegginton/velvet.git";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    builders-use-substitutes = true;
    substituters = [
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # Flake outputs
  outputs =
    { self
    , nixpkgs
    , home-manager
    , nix-github-actions
    , git-hooks
    , ...
    }:

    let
      inherit (nixpkgs) lib;

      # Supported systems for multi-platform outputs
      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;

      # Helper to generate attributes for all systems
      forAllSystems = lib.genAttrs systems;

      # Combine the categorized allowlists for all configured systems.
      unfreePackages = lib.concatLists (lib.attrValues (import ./lib/unfree-packages.nix));

      # nixos-images still sets an initrd option removed by newer nixpkgs.
      # TODO: Remove this override and its installer call sites once nixos-images fixes the removed option.
      installerInitrdCompatibility = { options, ... }:
        let
          modulePath = "${self.inputs.nixos-images}/nix/restore-remote-access.nix";
          upstream = import modulePath;
        in
        {
          disabledModules = [ modulePath ];
          boot.initrd.systemd =
            builtins.removeAttrs upstream.boot.initrd.systemd [ "enable" ]
            // lib.optionalAttrs (options.boot.initrd.systemd.enable.visible or true) {
              enable = true;
            };
        };

      # Configured nixpkgs instances for each system
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config = {
            # Allow specific unfree packages
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
            nvidia.acceptLicense = true;
          };
          # Apply system-wide overlays
          overlays = with self.inputs; [
            nix-topology.overlays.default
            nix-topology.overlays.topology
            run0-sudo-shim.overlays.default
            # velvet.overlays.default
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
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

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
        checks = lib.getAttrs githubPlatformsForSystems self.outputs.checks;
      };

      # Continuous integration checks
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          # Git pre-commit hooks check
          git-hooks-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              check-merge-conflicts.enable = true;
              end-of-file-fixer.enable = true;
              trim-trailing-whitespace.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              nixpkgs-fmt.enable = true;
              actionlint.enable = true;
              prettier = {
                enable = true;
                settings = {
                  print-width = 100;
                  prose-wrap = "preserve";
                };
                excludes = [
                  "infrastructure/tailscale_acl\\.json$"
                  "infrastructure/config\\.tf\\.json$"
                  "^secrets/.*\\.ya?ml$"
                ];
              };
              gitleaks = {
                enable = true;
                name = "gitleaks";
                entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose";
                args = [ ];
                pass_filenames = false;
              };
            };
          };

          # Network topology diagram
          topology = self.outputs.packages.${system}.topology;

          # Development shells
          devShell-default = self.outputs.devShells.${system}.default;
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          ghost-gs60 = self.outputs.nixosConfigurations.ghost-gs60.config.system.build.toplevel;
          latitude-7390 = self.outputs.nixosConfigurations.latitude-7390.config.system.build.toplevel;
          steamdeck = self.outputs.nixosConfigurations.steamdeck.config.system.build.toplevel;
          steammachine = self.outputs.nixosConfigurations.steammachine.config.system.build.toplevel;
          MCCLT5CG53030HM-wsl =
            self.outputs.nixosConfigurations."MCCLT5CG53030HM-wsl".config.system.build.toplevel;
          infector-iso = self.outputs.packages.${system}.infector-iso;
          infector-netboot = self.outputs.packages.${system}.infector-netboot;
          infector-kexec = self.outputs.packages.${system}.infector-kexec;
        }
      );

      # Legacy packages for backward compatibility
      legacyPackages = nixpkgsFor;

      # System-specific packages (like network topology and ISO images)
      packages = forAllSystems (
        system:
        {
          # Terranix evaluated Terraform JSON configuration
          terranix-config = self.inputs.terranix.lib.terranixConfiguration {
            inherit system;
            pkgs = nixpkgsFor.${system};
            modules = [ ./infrastructure ];
          };

          # Network topology diagram
          topology =
            (import self.inputs.nix-topology {
              pkgs = nixpkgsFor.${system};
              modules = [
                ./topology.nix
                { nixosConfigurations = self.outputs.nixosConfigurations; }
              ];
            }).config.output;

          # celld distributed Durable Objects daemon
          celld = nixpkgsFor.${system}.celld;
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          infector-iso = self.nixosConfigurations.infector.config.system.build.isoImage;
          infector-netboot = self.nixosConfigurations.infector-netboot.config.system.build.netboot;
          infector-kexec = self.nixosConfigurations.infector-kexec.config.system.build.kexecInstallerTarball;
        }
      );

      # Development shells for various tasks
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.callPackage ./shell.nix {
          terranix = self.inputs.terranix;
          gitHooksCheck = self.outputs.checks.${system}.git-hooks-check;
        };
      });

      # NixOS host configurations
      nixosConfigurations = {
        # MSI GS60 Ghost Laptop
        ghost-gs60 = self.outputs.lib.nixosSystem { hostname = "ghost-gs60"; };

        # Dell Latitude 7390 Laptop
        latitude-7390 = self.outputs.lib.nixosSystem { hostname = "latitude-7390"; };

        # Valve Steam Deck Handheld
        steamdeck = self.outputs.lib.nixosSystem { hostname = "steamdeck"; };

        # Valve Steam Machine Console
        steammachine = self.outputs.lib.nixosSystem { hostname = "steammachine"; };

        # Custom unattended installation media (Live ISO)
        infector = self.outputs.lib.nixosSystem {
          hostname = "infector";
          modules = [ self.inputs.nixos-images.nixosModules.image-installer ];
        };

        # Unattended network boot installation media (Netboot)
        infector-netboot = self.outputs.lib.nixosSystem {
          hostname = "infector";
          modules = [
            self.inputs.nixos-images.nixosModules.netboot-installer
            installerInitrdCompatibility
          ];
        };

        # Unattended in-place installation media (Kexec Tarball)
        infector-kexec = self.outputs.lib.nixosSystem {
          hostname = "infector";
          modules = [
            self.inputs.nixos-images.nixosModules.kexec-installer
            installerInitrdCompatibility
          ];
        };

        # Windows Subsystem for Linux environment
        "MCCLT5CG53030HM-wsl" = self.outputs.lib.nixosSystem { hostname = "MCCLT5CG53030HM-wsl"; };
      };
    };
}
