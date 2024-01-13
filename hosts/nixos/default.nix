# NixOS.
#
# Default configuration applies to all NixOS hosts.
{
  inputs,
  outputs,
  hostname,
  username,
  desktop,
  platform,
  stateVersion,
  modulesPath,
  pkgs,
  config,
  lib,
  ...
}: {
  # Modules
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      (modulesPath + "/installer/scan/not-detected.nix")
      ./modules/boot.nix
      ./modules/system.nix
      ./modules/documentation.nix

      ./${hostname}
      ./modules/firewall.nix
      ./modules/ssh.nix
      ./modules/tailescale.nix
      ./modules/smartmon.nix
      ./modules/console
      ./modules/users/root.nix
      ./modules/users/${username}.nix
    ]
    # Optional modules
    ++ lib.optional (desktop != null) ./modules/desktop;

  # Default sops configuration
  sops.defaultSopsFile = ../../secrets.yaml;

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
}
