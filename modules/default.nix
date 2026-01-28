{
  self,
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:

rec {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./environment/account.nix
    ./environment/issue.nix
    ./environment/login.nix
    ./environment/packages.nix
    ./display/gnome.nix
    ./display/niri.nix
    ./hardware/bluetooth.nix
    ./hardware/cpu.nix
    ./hardware/disks.nix
    ./programs/alacritty.nix
    ./programs/chromium.nix
    ./programs/dconf.nix
    ./programs/firefox.nix
    ./programs/sherlock-launcher.nix
    ./programs/steam.nix
    ./security/apparmor.nix
    ./security/pam.nix
    ./security/polkit.nix
    ./security/pwquality.nix
    ./security/sudo.nix
    ./security/run0.nix
    ./security/tpm2.nix
    ./services/backup.nix
    ./services/bitmagnet.nix
    ./services/calmav.nix
    ./services/displaymanager.nix
    ./services/flatpak.nix
    ./services/frigate.nix
    ./services/getty.nix
    ./services/home-assistant.nix
    ./services/immich.nix
    ./services/jellyfin.nix
    ./services/journald.nix
    ./services/lldap.nix
    ./services/nginx.nix
    ./services/pipewire.nix
    ./services/silverbullet.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/timesyncd.nix
    ./services/usbguard.nix
    ./users/ldap.nix
    ./users/root.nix
    ./virtualisation/docker.nix
    ./virtualisation/vm-variant.nix
    ./virtualisation/waydroid.nix
    ./console.nix
    ./environment.nix
    ./networking.nix
    ./secrets.nix
  ];

  system = {
    # state version for nixos modules
    stateVersion = config.system.nixos.release;

    # custom distro metadata
    nixos = {
      distroName = lib.mkDefault "Residence";
      distroId = lib.mkDefault "residence";
      vendorName = lib.mkDefault self.outputs.lib.maintainers.dominicegginton.name;
      vendorId = lib.mkDefault self.outputs.lib.maintainers.dominicegginton.github;
      tags = [ (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux") ];
    };
  };

  # system color scheme
  scheme = "${pkgs.theme}/residence-theme.yaml";

  # system time zone
  time.timeZone = "Europe/London";

  # system locale
  i18n.defaultLocale = "en_GB.UTF-8";
  nixpkgs.overlays = [ self.outputs.overlays.default ];

  # nix settings
  nix = {
    # nix pkg
    package = pkgs.nix;

    # automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # automatic optimise of the nix store
    optimise.automatic = lib.mkDefault true;

    # disable channel updates
    channel.enable = false;

    # nix registry entries
    registry = lib.mapAttrs (_: value: { flake = value; }) self.inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # nix settings
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "auto-allocate-uids"
        "cgroups"
        "fetch-closure"
        "parse-toml-timestamps"
        "recursive-nix"
        "pipe-operators"
      ];

      # garbage collection settings
      min-free = builtins.toString (30 * 1024 * 1024 * 1024); # 30 GB
      min-free-check-interval = 1;

      # disable global registry
      flake-registry = "";

      # performance optimizations for faster rebuilds
      # keep-outputs = true; # keep build outputs
      # keep-derivations = true; # keep derivations for faster rebuilds

      # performance settings
      eval-cache = true; # enable caching
      narinfo-cache-positive-ttl = 3600; # longer cache for existing narinfos
      narinfo-cache-negative-ttl = 60; # quicker retries on missing narinfo
      fsync-metadata = false; # faster on SSDs
      connect-timeout = 10; # faster timeouts
      max-substitution-jobs = 128; # increased parallel substitutions
      http-connections = 128; # increased parallel connections
      cores = 0; # use all available CPU cores
      max-jobs = "auto"; # use all available CPU cores
      keep-build-log = false; # dont keep build logs
      compress-build-log = true; # compress build logs
      require-sigs = true;
      allowed-users = [
        "root"
        "@wheel"
      ];
    };
  };

  boot = {
    consoleLogLevel = 0; # log all boot messages
    initrd.verbose = false; # disable verbose initrd
    loader = {
      systemd-boot.enable = true; # enable systemd-boot
      efi.canTouchEfiVariables = true; # allow efi variables modification
    };

    plymouth = {
      enable = true;
      themePackages = [ pkgs.plymouth-theme ]; # boot theme package
      theme = pkgs.plymouth-theme.name; # set boot theme
    };

    kernelParams = [
      "fips=1"
      "audit=1"
      "audit_backlog_limit=8192"
    ];

    kernel.sysctl = {
      "net.ipv4.tcp_syncookies" = "1";
      "kernel.kptr_restrict" = 1;
      "kernel.randomize_va_space" = 2;
    };
  };

  security.lockKernelModules = lib.mkDefault true;
  security.protectKernelImage = lib.mkDefault true;
  security.unprivilegedUsernsClone = lib.mkDefault true;

  programs = {
    gnupg.agent.enable = true;
    ssh.startAgent = lib.mkIf (config.services.gnome.gcr-ssh-agent.enable == false) true;
    deadman.enable = true;
  };

  environment.defaultPackages = lib.mkForce [ ];

  services = {
    dbus.enable = true; # system bus
    smartd.enable = true; # disk health monitoring
    thermald.enable = true; # thermal management
    upower.enable = true; # power management
    fwupd.enable = true; # firmware updates
    fstrim.enable = true; # periodic trim for ssd
  };

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = [
      self.inputs.base16.homeManagerModule
      {
        inherit scheme;
        home = {
          stateVersion = "25.05";
          enableNixpkgsReleaseCheck = false;
        };
        programs = {
          bash.enable = true;
          info.enable = true;
          hstr.enable = true;
        };
      }
    ];
  };
}
