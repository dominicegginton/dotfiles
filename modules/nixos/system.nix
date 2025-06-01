{ inputs, config, lib, pkgs, nixConfig, stateVersion, ... }:

{
  config = {
    system = {
      inherit stateVersion;
      autoUpgrade = {
        enable = true;
        dates = "02:00";
        flake = "github:dominicegginton/dotfiles";
        operation = "switch";
        persistent = true;
      };
      activationScripts.diff.text = ''
        if [[ -e /run/current-system ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        fi
      '';
    };
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "nl_NL.UTF-8";
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
        max-free = "10G";
        min-free-check-interval = 1;
        trusted-users = [ "dom" "root" "@wheel" ];
      };
    };
    boot = {
      consoleLogLevel = 0;
      initrd.verbose = false;
      plymouth = {
        enable = true;
        theme = "spinner";
      };
    };
    console = {
      enable = true;
      earlySetup = true;
      keyMap = "uk";
      colors = config.scheme.toList;
    };
    security = {
      sudo.enable = true;
      polkit.enable = true;
    };
    documentation = {
      enable = true;
      man.enable = true;
      doc.enable = true;
      dev.enable = true;
      info.enable = true;
      nixos.enable = true;
    };
    services = {
      clamav = {
        scanner.enable = true;
        updater.enable = true;
        daemon.enable = true;
      };
      dbus.enable = true;
      smartd.enable = true;
      thermald.enable = true;
    };
    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        promptInit = "autoload -U promptinit && promptinit";
      };
      gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry;
      };
    };
    environment = {
      variables = {
        EDITOR = "vim";
        SYSTEMD_EDITOR = "vim";
        VISUAL = "vim";
        PAGER = "less";
      };
      systemPackages = with pkgs; [
        clamav
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
        jq
        less
        bat
        git
        git-lfs
        pinentry
        pinentry-curses
        status
        nun
        nearch
      ];
    };
  };
}
