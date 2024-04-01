{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux isDarwin;
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
      package = pkgs.nix;
      gc.automatic = true;
      optimise.automatic = true;
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        experimental-features = ["nix-command" "flakes"];

        # Set auto optimise store to false on darwin
        # to avoid the issue with the store being locked
        # and causing nix to hang when trying to build
        # a derivation. This is a temporary fix until
        # the issue is resolved in nix.
        # SEE: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store =
          if isDarwin
          then false
          else true;
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
        inputs.nix-alien.overlays.default
      ];
    };

    boot = mkIf isLinux {
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
      plymouth = mkIf (isLinux && config.modules.desktop.enable) {
        enable = true;
        theme = "spinner";
      };
    };

    i18n.defaultLocale = mkIf isLinux cfg.location;
    i18n.extraLocaleSettings = mkIf isLinux {
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
    time.timeZone = mkIf isLinux cfg.timezone;

    documentation = {
      enable = true;
      man.enable = lib.mkDefault true;
      nixos.enable = lib.mkDefault false;
      info.enable = lib.mkDefault false;
      doc.enable = lib.mkDefault false;
    };

    security = mkIf isLinux {
      sudo.enable = true;
      polkit.enable = true;
      rtkit.enable = true;
    };

    services.xserver.layout = mkIf isLinux cfg.keyboardLayout;
    services.dbus.enable = mkIf isLinux true;
    services.smartd.enable = mkIf isLinux true;
    services.thermald.enable = mkIf isLinux true;

    system.activationScripts.enebale = mkIf isDarwin true;
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

      systemPackages = with pkgs;
        [
          gitMinimal # git
          vim # vim
          home-manager # home-manager
          killall # killall processes utility
          unzip # unzip utility
          wget # http client
          htop-vim # system monitor
          btop # better system monitor
          rebuild-host
          rebuild-home
          rebuild-configuration
          upgrade-configuration
          cleanup-trash
          shutdown-host
          reboot-host
          suspend-host
          hibernate-host
        ]
        ++ optionals isLinux [
          usbutils # usb utilities
          nvme-cli # nvme command line interface
          smartmontools # control and monitor stroage systems
        ];
    };
  };
}
