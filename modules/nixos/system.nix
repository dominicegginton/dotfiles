{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.system;
in {
  options.modules.system = {
    stateVersion = mkOption {
      type = types.str;
      default = "20.09";
      description = "The state version to use for the system";
    };

    nixpkgs.hostPlatform = mkOption {
      type = types.str;
      default = "x86_64-linux";
      description = "The host platform to use for the system";
    };

    nixpkgs.allowUnfree = mkOption {
      type = types.bool;
      default = false;
      description = "Allow unfree packages to be installed";
    };

    nixpkgs.permittedInsecurePackages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Permitted insecure packages to be installed";
    };

    location = mkOption {
      type = types.str;
      default = "en_GB.utf8";
      description = "The system location.";
    };

    timezone = mkOption {
      type = types.str;
      default = "Europe/London";
      description = "The system timezone.";
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = "gb";
      description = "The keyboard layout to use.";
    };
  };

  config = {
    nix = {
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

    nixpkgs = {
      hostPlatform = cfg.nixpkgs.hostPlatform;
      config.allowUnfree = cfg.nixpkgs.allowUnfree;
      config.allowUnfreePredicate = cfg.nixpkgs.allowUnfree;
      config.joypixels.acceptLicense = cfg.nixpkgs.allowUnfree;
      config.permittedInsecurePackages = cfg.nixpkgs.permittedInsecurePackages;
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        inputs.neovim-nightly-overlay.overlay
        inputs.todo.overlays.default
      ];
    };

    boot = {
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
      kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
      plymouth = mkIf config.modules.desktop.enable {
        enable = true;
        theme = "spinner";
      };
    };

    time.timeZone = cfg.timezone;
    i18n.defaultLocale = cfg.location;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.location;
      LC_IDENTIFICATION = cfg.location;
      LC_MEASUREMENT = cfg.location;
      LC_MONETARY = cfg.location;
      LC_NAME = cfg.location;
      LC_NUMERIC = cfg.location;
      LC_PAPER = cfg.location;
      LC_TELEPHONE = cfg.location;
      LC_TIME = cfg.location;
    };

    documentation = {
      enable = true;
      man.enable = true;
      nixos.enable = true;
      info.enable = true;
      doc.enable = true;
    };

    security = {
      sudo.enable = true;
      polkit.enable = true;
      rtkit.enable = true;
    };

    services.xserver.layout = cfg.keyboardLayout;
    services.dbus.enable = true;
    services.smartd.enable = true;
    services.thermald.enable = true;

    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };

    system.stateVersion = cfg.stateVersion;

    environment = {
      variables.EDITOR = "vim";
      variables.SYSTEMD_EDITOR = "vim";
      variables.VISUAL = "vim";
      variables.FLAKE = "~/.dotfiles";

      systemPackages = with pkgs; [
        unstable.nh
        nvd
        home-manager # home-manager

        file # file utility
        gitMinimal # git
        vim # vim
        killall # killall processes utility
        unzip # unzip utility
        wget # http client
        htop-vim # system monitor
        btop # better system monitor

        usbutils # usb utilities
        nvme-cli # nvme command line interface
        smartmontools # control and monitor stroage systems

        rebuild-host
        rebuild-home
        rebuild-configuration
        upgrade-configuration
        cleanup-trash
        shutdown-host
        reboot-host
        suspend-host
        hibernate-host
      ];
    };
  };
}
