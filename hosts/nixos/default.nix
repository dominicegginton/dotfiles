# A default nixos configuration that applies to all hosts
{
  hostname,
  username,
  desktop,
  installer,
  platform,
  inputs,
  outputs,
  stateVersion,
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      (modulesPath + "/installer/scan/not-detected.nix")
      ./${hostname}
      ./modules/firewall.nix
      ./modules/ssh.nix
      ./modules/tailescale.nix
      ./modules/smartmon.nix
      ./modules/console
      ./modules/users/root.nix
      ./modules/users/${username}.nix
    ]
    ++ lib.optional (desktop != null) ./modules/desktop;

  # Set the default sops secrets configuration file
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  # Enable man documentation for all packages
  documentation = {
    enable = true;
    man.enable = lib.mkDefault true;
    nixos.enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    doc.enable = lib.mkDefault false;
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
      # Enable ipv4 and ipv6 forwarding
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;

      # Enable BBR congestion control and fq queueing
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048;
    cores = 3;
    graphics = false;
  };

  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    keyMap = "uk";
    packages = with pkgs; [tamzen];
  };

  i18n = {
    defaultLocale = "en_GB.utf8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.utf8";
      LC_IDENTIFICATION = "en_GB.utf8";
      LC_MEASUREMENT = "en_GB.utf8";
      LC_MONETARY = "en_GB.utf8";
      LC_NAME = "en_GB.utf8";
      LC_NUMERIC = "en_GB.utf8";
      LC_PAPER = "en_GB.utf8";
      LC_TELEPHONE = "en_GB.utf8";
      LC_TIME = "en_GB.utf8";
    };
  };
  services.xserver.layout = "gb";
  time.timeZone = "Europe/London";

  environment = {
    defaultPackages = with pkgs; [
      gitMinimal
      vim
      home-manager
      unzip
      usbutils
      wget
    ];
    systemPackages = with pkgs; [
      workspace.rebuild-host
      workspace.rebuild-home
      workspace.rebuild-configuration
      workspace.upgrade-configuration
      workspace.shutdown-host
      workspace.reboot-host
    ];
    variables = {
      EDITOR = "vim";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    hostPlatform = platform;
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.neovim-nightly-overlay.overlay
      inputs.nixneovimplugins.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    optimise.automatic = true;
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  security = {
    sudo.execWheelOnly = true;
    polkit.enable = true;
    rtkit.enable = true;
  };

  programs.command-not-found.enable = false;

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];

  system = {
    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };

    stateVersion = stateVersion;
  };
}