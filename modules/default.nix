## Modules: default.nix
## Simple module header
{
  self,
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:

let
  selfRef = value: { "self" = value; };
in

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
    ./services/bitmagnet.nix
    ./services/calmav.nix
    ./services/displaymanager.nix
    # ./services/dit0.nix
    ./services/flatpak.nix
    ./services/frigate.nix
    ./services/getty.nix
    ./services/home-assistant.nix
    ./services/immich.nix
    ./services/jellyfin.nix
    ./services/journald.nix
    ./services/logind.nix
    ./services/nginx.nix
    ./services/ollama.nix
    ./services/pipewire.nix
    ./services/silverbullet.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/tsidp.nix
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
    stateVersion = lib.mkForce config.system.nixos.release;

    # custom distro metadata
    nixos = {
      distroName = lib.mkForce "Residence";
      distroId = lib.mkForce "residence";
      vendorName = lib.mkForce self.outputs.lib.maintainers.dominicegginton.name;
      vendorId = lib.mkForce self.outputs.lib.maintainers.dominicegginton.github;
      tags = lib.mkForce [ (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux") ];
    };
  };

  # system color scheme
  scheme = lib.mkForce "${pkgs.theme}/residence-theme.yaml";

  # system time zone
  time.timeZone = lib.mkDefault "Europe/London";

  # system locale
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";
  nixpkgs.overlays = lib.mkForce [ self.outputs.overlays.default ];

  nix = {
    # nix pkg
    package = lib.mkForce pkgs.nix;

    # automatic garbage collection
    gc = {
      automatic = lib.mkForce true;
      dates = lib.mkForce "weekly";
      options = lib.mkForce "--delete-older-than 7d";
    };

    # automatic optimise of the nix store
    optimise.automatic = lib.mkForce true;

    # disable channel updates
    channel.enable = lib.mkForce false;

    # nix registry entries
    registry = lib.mapAttrs (_: value: { flake = value; }) (self.inputs // selfRef self);
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
      min-free-check-interval = lib.mkForce 1;

      # disable global registry
      flake-registry = lib.mkDefault "";

      # performance optimizations for faster rebuilds
      # keep-outputs = true; # keep build outputs
      # keep-derivations = true; # keep derivations for faster rebuilds

      # performance settings
      eval-cache = lib.mkForce true; # enable caching
      narinfo-cache-positive-ttl = lib.mkForce 3600; # longer cache for existing narinfos
      narinfo-cache-negative-ttl = lib.mkForce 60; # quicker retries on missing narinfo
      fsync-metadata = lib.mkForce false; # faster on SSDs
      connect-timeout = lib.mkForce 10; # faster timeouts
      max-substitution-jobs = lib.mkForce 128; # increased parallel substitutions
      http-connections = lib.mkForce 128; # increased parallel connections
      cores = lib.mkForce 0; # use all available CPU cores
      max-jobs = lib.mkForce "auto"; # use all available CPU cores
      keep-build-log = lib.mkForce false; # dont keep build logs
      compress-build-log = lib.mkForce true; # compress build logs
      require-sigs = lib.mkForce true;
      allowed-users = lib.mkForce [
        "root"
        "@wheel"
      ];
    };
  };

  boot = {
    consoleLogLevel = lib.mkForce 0; # log all boot messages
    initrd.verbose = lib.mkForce false; # disable verbose initrd
    loader = {
      grub = {

      };
      systemd-boot.enable = lib.mkForce true; # enable systemd-boot
      efi.canTouchEfiVariables = lib.mkForce true; # allow efi variables modification
      efi.efiSysMountPoint = lib.mkForce "/boot";
    };

    plymouth = {
      enable = lib.mkForce true;
      theme = lib.mkForce pkgs.plymouth-theme.name; # set boot theme
      themePackages = lib.mkForce [ pkgs.plymouth-theme ]; # boot theme package
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
    gnupg.agent.enable = lib.mkForce true;
    ssh.startAgent = lib.mkIf (config.services.gnome.gcr-ssh-agent.enable == false) true;
    deadman.enable = lib.mkForce true;
  };

  environment.defaultPackages = lib.mkForce [ ];

  services = {
    dbus.enable = lib.mkForce true;
    smartd.enable = lib.mkForce true;
    thermald.enable = lib.mkForce true;
    upower.enable = lib.mkForce true;
    fwupd.enable = lib.mkForce true;
    fstrim.enable = lib.mkForce true;
  };

  home-manager = {
    useGlobalPkgs = lib.mkForce true;
    backupFileExtension = lib.mkForce "backup";
    sharedModules = [
      self.inputs.base16.homeManagerModule
      {
        inherit scheme;
        home = {
          stateVersion = lib.mkForce "25.05";
          enableNixpkgsReleaseCheck = lib.mkForce false;
        };
        programs = {
          bash.enable = lib.mkForce true;
          info.enable = lib.mkForce true;
          hstr.enable = lib.mkForce true;
        };
      }
    ];
  };
}
