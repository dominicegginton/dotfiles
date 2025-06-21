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
        max-free = "10G";
        min-free-check-interval = 1;
        trusted-users = [ "dom" "root" "@wheel" ];
      };
    };
    boot = {
      consoleLogLevel = 0;
      initrd.verbose = false;
    };
    console = {
      enable = true;
      earlySetup = true;
      keyMap = "uk";
      font = "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
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
        EDITOR = "helix";
        SYSTEMD_EDITOR = "helix";
        VISUAL = "helix";
        PAGER = "less";
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_DBUS_REMOTE = "1";
      };
      etc = {
        issue.text = ''
          ▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖▗▄▄▄▖▗▄▄▄ ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖▗▄▄▄▖
          ▐▌ ▐▌▐▌   ▐▌     █  ▐▌  █▐▌   ▐▛▚▖▐▌▐▌   ▐▌   
          ▐▛▀▚▖▐▛▀▀▘ ▝▀▚▖  █  ▐▌  █▐▛▀▀▘▐▌ ▝▜▌▐▌   ▐▛▀▀▘
          ▐▌ ▐▌▐▙▄▄▖▗▄▄▞▘▗▄█▄▖▐▙▄▄▀▐▙▄▄▖▐▌  ▐▌▝▚▄▄▖▐▙▄▄▖
        '';
        "os-release".text = ''
            ANSI_COLOR="1;34"
            ID=residence
            NAME="Residence"
            PRETTY_NAME="Residence"
            VERSION="rolling"
            VERSION_CODENAME="rolling"
            VERSION_ID="rolling"
            BUILD_ID="rolling"
            IMAGE_ID="rolling"
            IMAGE_VERSION="rolling"
            HOME_URL="https://github.com/${pkgs.lib.maintainers.dominicegginton.github}/dotfiles"
            DOCUMENTATION_URL="https://${pkgs.lib.maintainers.dominicegginton.github}/dotfiles"
            SUPPORT_URL="https://github.com/${pkgs.lib.maintainers.dominicegginton.github}/dotfiles/issues"
            BUG_REPORT_URL="https://github.com/${pkgs.lib.maintainers.dominicegginton.github}/dotfiles/issues"
      '';
      };
      systemPackages = with pkgs; [
        uutils-coreutils-noprefix
        bat
        clamav
        cachix
        file
        trash-cli
        git
        git-lfs
        gitui
        helix
        killall
        hwinfo
        unzip
        wget
        htop-vim
        bottom
        fzf
        ripgrep-all
        du
        dua
        tree
        jq
        fx
        gum
        fd
        jq
        less
        pinentry
        pinentry-curses
        status
        dnsutils
        curl
        openssl
        termshark
        tzdata
        unrar
        unzip
        zip
        which
        whois
        psmisc
        usbutils
        nvme-cli
        smartmontools
        caligula
      ];
    };
  };
}

