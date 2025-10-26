{ inputs, modulesPath, config, lib, pkgs, nixConfig, ... }:

rec {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./display/gnome.nix
    ./display/niri.nix
    ./display/steamos.nix
    ./hardware/bluetooth.nix
    ./hardware/disks.nix
    ./programs/alacritty.nix
    ./programs/chromium.nix
    ./programs/firefox.nix
    ./programs/sherlock-launcher.nix
    ./programs/steam.nix
    ./programs/vscode.nix
    ./programs/zsh.nix
    ./services/calmav.nix
    ./services/davfs2.nix
    ./services/flatpak.nix
    ./services/frigate.nix
    ./services/home-assistant.nix
    ./services/mosquitto.nix
    ./services/pipewire.nix
    ./services/printing.nix
    ./services/silverbullet.nix
    ./services/tailscale.nix
    ./services/tlp.nix
    ./services/unifi.nix
    ./services/zabbix.nix
    ./virtualisation/virtualisation.nix
    ./virtualisation/docker.nix
    ./virtualisation/waydroid.nix
    ./backup.nix
    ./console.nix
    ./environment.nix
    ./networking.nix
    ./secrets.nix
    ./upgrade.nix
    ./users.nix
  ];

  system = {
    stateVersion = config.system.nixos.release;
    nixos = {
      distroName = lib.mkDefault "Residence";
      distroId = lib.mkDefault "residence";
      vendorName = lib.mkDefault pkgs.lib.maintainers.dominicegginton.name;
      vendorId = lib.mkDefault pkgs.lib.maintainers.dominicegginton.github;
      tags = [
        (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux")
        (lib.optionalString (pkgs.stdenv.isDarwin) "residence-darwin")
      ];
    };
  };
  scheme = "${pkgs.theme}/residence-theme.yaml";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  nix = {
    package = pkgs.unstable.nix;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = lib.mkDefault true;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = nixConfig // {
      min-free = "8G";
      max-free = "120G";
      min-free-check-interval = 1;
      trusted-users = [ "root" "@wheel" ];
    };
  };
  documentation = {
    enable = true;
    man.enable = true;
    doc.enable = true;
    dev.enable = true;
    info.enable = true;
  };
  services.openssh.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry;
    };
    ssh.startAgent = true;
    command-not-found.enable = true;
  };
  hardware.cpu = {
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  virtualisation.vmVariant.users = {
    groups.nixosvmtest = { };
    users.nix = {
      description = "NixOS VM Test User";
      isNormalUser = true;
      initialPassword = "";
      group = "nixosvmtest";
    };
  };
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  security = {
    sudo.enable = true;
    polkit.enable = true;
  };
  hardware.system76.power-daemon.enable = true;
  services = {
    dbus.enable = true;
    smartd.enable = true;
    thermald.enable = true;
    upower.enable = true;
  };
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.base16.homeManagerModule
      inputs.ags.homeManagerModules.default
      {
        inherit scheme;
        home.stateVersion = "25.05";
        programs = {
          bash.enable = true;
          info.enable = true;
          hstr.enable = true;
        };
      }
      ../home-manager
    ];
  };
}
