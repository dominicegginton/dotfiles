{
  inputs,
  stateVersion,
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./networking.nix
    ./virtualisation.nix
    ./bluetooth.nix
    ./users.nix
    ./console.nix
    ./desktop
    ./services
  ];

  options.modules.nixos.role = mkOption rec {
    type = with types; string;
  };

  config = rec {
    nix = rec {
      package = pkgs.unstable.nix;
      gc.automatic = mkForce true;
      optimise.automatic = mkForce true;
      registry = mapAttrs (_: value: {flake = value;}) inputs;
      nixPath = mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = rec {
        experimental-features = mkForce ["nix-command" "flakes"];
        keep-outputs = mkForce true;
        keep-derivations = mkForce true;
        warn-dirty = mkForce false;
        auto-optimise-store = mkForce true;
        trusted-users = mkForce ["root" "@wheel"];
        trusted-public-keys = mkForce [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];
        substituters = mkForce [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];
      };
    };

    boot = rec {
      consoleLogLevel = mkForce 0;
      initrd.verbose = mkForce false;
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

    system.stateVersion = stateVersion;
    sops.defaultSopsFile = ../../secrets.yaml;
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    services.dbus.enable = true;
    services.smartd.enable = true;
    services.thermald.enable = true;
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.pinentryFlavor = "curses";
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
        pinentry-curses
      ];
    };
  };
}
