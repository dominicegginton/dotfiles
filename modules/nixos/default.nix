{ inputs, config, lib, pkgs, modulesPath, stateVersion, theme, ... }:

with lib;

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./bluetooth.nix
    ./console.nix
    ./display.nix
    ./distributed-builds.nix
    ./documentation.nix
    ./environment.nix
    ./gpg.nix
    ./home-assistant.nix
    ./home-manager.nix
    ./networking.nix
    ./plasma.nix
    ./secrets.nix
    ./security.nix
    ./steam.nix
    ./sway.nix
    ./theme.nix
    ./unifi.nix
    ./users.nix
    ./virtualisation.nix
    ./zsh.nix
  ];

  config = {
    system.stateVersion = stateVersion;
    nix = {
      package = pkgs.unstable.nix;
      gc.automatic = true;
      optimise.automatic = true;
      registry = mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        log-lines = 100;
        connect-timeout = 30;
        fallback = true;
        warn-dirty = true;
        keep-going = true;
        keep-outputs = true;
        keep-derivations = true;
        auto-optimise-store = true;
        min-free = 10000000000;
        max-free = 20000000000;
        trusted-users = [ "dom" "nixremote" "root" "@wheel" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "dominicegginton.cachix.org-1:P8AQ3itMEVevMqAzCKiPyvJ6l1a9NVaFPAXJqb9mAaY="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://dominicegginton.cachix.org"
        ];
      };
    };
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;
    services.dbus.enable = true;
    services.smartd.enable = true;
    services.thermald.enable = true;
    system.activationScripts.diff.text = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
    services.udev.packages = [ pkgs.android-udev-rules ];
    environment.systemPackages = with pkgs; [
      cachix
      file
      gitMinimal
      vim
      killall
      hwinfo
      unzip
      wget
      htop-vim
      bottom
      usbutils
      nvme-cli
      smartmontools
      fzf
      ripgrep
      fd
      bat
      git
      git-lfs
      pinentry
      pinentry-curses
      collect-garbage
      host-status
      secrets-sync
    ];
  };
}
