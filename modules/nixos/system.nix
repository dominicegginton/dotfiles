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
      };
      etc.issue.text = ''
        ▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖▗▄▄▄▖▗▄▄▄ ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖▗▄▄▄▖
        ▐▌ ▐▌▐▌   ▐▌     █  ▐▌  █▐▌   ▐▛▚▖▐▌▐▌   ▐▌   
        ▐▛▀▚▖▐▛▀▀▘ ▝▀▚▖  █  ▐▌  █▐▛▀▀▘▐▌ ▝▜▌▐▌   ▐▛▀▀▘
        ▐▌ ▐▌▐▙▄▄▖▗▄▄▞▘▗▄█▄▖▐▙▄▄▀▐▙▄▄▖▐▌  ▐▌▝▚▄▄▖▐▙▄▄▖
      '';
      systemPackages = with pkgs; [
        (lib.hiPrio uutils-coreutils-noprefix)
        (lib.hiPrio uutils-findutils)
        (lib.hiPrio uutils-diffutils)
        (if stdenv.isLinux then trashy else darwin.trash)
        helix
        fzf
        ripgrep
        ripgrep-all
        less
        tree
        fd
        file
        dua
        gum
        hwinfo
        usbutils
        nvme-cli
        smartmontools
        clamav
        bottom
        status
        openssl
        openssh
        curl
        wget
        dnsutils
        git
        git-lfs
        pinentry
        pinentry-curses
      ];
    };
  };
}

