{ inputs, config, lib, pkgs, stateVersion, ... }:

with lib;

{
  imports = [
    ./users.nix
    ./console
    ./display
    ./services
  ];

  config = {
    system.stateVersion = stateVersion;
    sops.defaultSopsFile = ../../secrets.yaml;
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

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

    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;

    documentation = {
      enable = true;
      man.enable = true;
      nixos.enable = true;
      info.enable = true;
      doc.enable = true;
    };

    security.sudo.enable = true;
    security.polkit.enable = true;
    security.rtkit.enable = true;

    services.dbus.enable = true;
    services.smartd.enable = true;
    services.thermald.enable = true;

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry;

    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };

    environment.systemPackages = with pkgs; [
      cachix
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
      fzf
      ripgrep
      fd
      bat
      git
      git-lfs
      pinentry
      pinentry-curses
    ];
  };
}
