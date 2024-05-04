{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.nixos;
in {
  imports = [
    ./networking.nix
    ./virtualisation.nix
    ./bluetooth.nix
    ./users.nix
    ./console.nix
    ./desktop
  ];

  options.modules.nixos = {
    stateVersion = mkOption {type = types.str;};
    nixpkgs.hostPlatform = mkOption {type = types.str;};
    nixpkgs.allowUnfree = mkOption {type = types.bool;};
    nixpkgs.permittedInsecurePackages = mkOption {
      type = types.listOf types.str;
      default = [];
    };
    location = mkOption {
      type = types.str;
      default = "en_GB.utf8";
    };
  };

  config = rec {
    nix = rec {
      package = pkgs.unstable.nix;
      gc.automatic = true;
      optimise.automatic = true;
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
        auto-optimise-store = true;
        trusted-users = ["root" "@wheel"];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];
      };
    };

    # nixpkgs = rec {
    #   hostPlatform = cfg.nixpkgs.hostPlatform;
    #   config.allowUnfree = cfg.nixpkgs.allowUnfree;
    #   config.allowUnfreePredicate = cfg.nixpkgs.allowUnfree;
    #   config.joypixels.acceptLicense = cfg.nixpkgs.allowUnfree;
    #   config.permittedInsecurePackages = cfg.nixpkgs.permittedInsecurePackages;
    #   overlays = [
    #     outputs.overlays.additions
    #     outputs.overlays.modifications
    #     outputs.overlays.unstable-packages
    #     inputs.neovim-nightly-overlay.overlay
    #   ];
    # };

    boot = rec {
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelModules = ["vhost_vsock"];
      kernelParams = [
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
      kernel.sysctl = rec {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };

    documentation = rec {
      enable = true;
      man.enable = true;
      nixos.enable = true;
      info.enable = true;
      doc.enable = true;
    };

    security = rec {
      sudo.enable = true;
      polkit.enable = true;
      rtkit.enable = true;
    };

    system.stateVersion = cfg.stateVersion;
    sops.defaultSopsFile = ../../secrets.yaml;
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    services.dbus.enable = true;
    services.smartd.enable = true;
    services.thermald.enable = true;
    system.activationScripts.diff = rec {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };

    environment = {
      variables.EDITOR = "vim";
      variables.SYSTEMD_EDITOR = "vim";
      variables.VISUAL = "vim";
      variables.NSM_FLAKE = "$HOME/.dotfiles";
      systemPackages = with pkgs; [
        nsm
        unstable.nh
        nvd
        home-manager
        file
        gitMinimal
        vim
        killall
        unzip
        wget
        htop-vim
        btop
        usbutils
        nvme-cli
        smartmontools
      ];
    };
  };
}
