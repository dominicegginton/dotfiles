{
  # modules/default.nix
  #
  # Base system module imports and core configuration for all NixOS systems in this flake.
  # Groups hardware, environment, security, service, and user modules for maintainability.
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
  # Base imports for all systems
  imports = [
    # Core hardware detection and VM support
    "${modulesPath}/installer/scan/not-detected.nix" # Hardware scan for installer
    "${modulesPath}/profiles/qemu-guest.nix" # QEMU VM profile

    # Console and display environments (GNOME, Niri)
    ./console.nix
    ./display/gnome.nix
    ./display/niri.nix

    # Environment modules (user shell, login, packages)
    ./environment.nix
    ./environment/account.nix
    ./environment/issue.nix
    ./environment/login.nix
    ./environment/packages.nix

    # Hardware modules (Bluetooth, CPU microcode)
    ./hardware/bluetooth.nix
    ./hardware/cpu.nix

    # Networking stack
    ./networking.nix

    # Program modules (user applications)
    ./programs/alacritty.nix
    ./programs/chromium.nix
    ./programs/dconf.nix
    ./programs/firefox.nix
    ./programs/sherlock-launcher.nix
    ./programs/steam.nix

    # Secrets management (Bitwarden, Google Secret Manager, etc.)
    ./secrets.nix

    # Security modules (AppArmor, PAM, Polkit, etc.)
    ./security/apparmor.nix
    ./security/pam.nix
    ./security/polkit.nix
    ./security/pwquality.nix
    ./security/run0.nix
    ./security/sudo.nix
    ./security/tpm2.nix

    # Service modules (system daemons, servers)
    ./services/beszel.nix
    ./services/bitmagnet.nix
    ./services/calmav.nix
    ./services/displaymanager.nix
    # ./services/dit0.nix # Disabled: experimental LDAP server
    ./services/flatpak.nix
    ./services/frigate.nix
    ./services/gcs-backup.nix
    ./services/github-runner.nix
    ./services/getty.nix
    ./services/home-assistant.nix
    ./services/immich.nix
    ./services/jellyfin.nix
    ./services/journald.nix
    ./services/logind.nix
    ./services/nginx.nix
    ./services/pipewire.nix
    ./services/silverbullet.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/timesyncd.nix
    ./services/tsidp.nix
    ./services/usbguard.nix

    # User modules (user accounts, LDAP, SSSD)
    ./users/ldap.nix
    ./users/sssd.nix
    ./users/root.nix

    # Virtualisation (Docker, VMs, WSL, Android)
    ./virtualisation/docker.nix
    ./virtualisation/vm-variant.nix
    ./virtualisation/waydroid.nix
    ./virtualisation/wsl.nix
  ];

  system = {
    # NixOS state version (enforced for system compatibility)
    stateVersion = lib.mkForce config.system.nixos.release;

    # Enforce branding for all systems
    nixos = {
      distroName = lib.mkForce "Residence"; # Branding: always "Residence"
      distroId = lib.mkForce "residence"; # Branding: always "residence"
      vendorName = lib.mkForce self.outputs.lib.maintainers.dominicegginton.name; # Branding
      vendorId = lib.mkForce self.outputs.lib.maintainers.dominicegginton.github; # Branding
      tags = lib.mkForce [
        (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux")
        (lib.optionalString config.wsl.enable "wsl")
      ];
    };
  };

  # System-wide monitoring
  services.beszel.enable = true;

  # System-wide color scheme (used by Home Manager and theming modules)
  scheme = lib.mkForce "${pkgs.theme}/residence-theme.yaml";

  # Default localization settings
  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";

  # Default overlays (allows user overlays to be appended)
  nixpkgs.overlays = lib.mkDefault [ self.outputs.overlays.default ];

  nix = {
    # Pin the Nix package version for reproducibility
    package = lib.mkForce pkgs.nix;

    # Enable automatic garbage collection (GC)
    gc = {
      automatic = lib.mkForce true; # Always enable GC
      dates = lib.mkForce "weekly"; # Run GC weekly
      options = lib.mkForce "--delete-older-than 7d"; # Remove store paths older than 7 days
    };

    # Enable automatic store optimisation
    optimise.automatic = lib.mkForce true;

    # Disable legacy channel updates (flakes only)
    channel.enable = lib.mkForce false;

    # Nix registry and nixPath for flake-based workflows
    registry = lib.mapAttrs (_: value: { flake = value; }) (self.inputs // selfRef self);
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # Nix daemon and CLI settings
    settings = {
      # Enable experimental features for modern Nix workflows
      experimental-features = [
        "flakes" # Flake support
        "nix-command" # Nix-command support
        "auto-allocate-uids" # Automatically allocate UIDs
        "cgroups" # Leverage cgroups for resource management
        "fetch-closure" # Enable fetch-closure support
        "parse-toml-timestamps" # Enable parse-toml-timestamps support
        "recursive-nix" # Enable recursive-nix support
        "pipe-operators" # Enable pipe-operators support
      ];

      # Minimum free space for builds (30GB)
      min-free = builtins.toString (30 * 1024 * 1024 * 1024); # 30 GB
      min-free-check-interval = lib.mkForce 1; # Check every 1s

      # Disable global registry (flake registry only)
      flake-registry = lib.mkDefault "";

      # Performance optimizations (uncomment to keep outputs/derivations)
      # keep-outputs = true; # keep build outputs
      # keep-derivations = true; # keep derivations for faster rebuilds

      # Performance and reliability settings
      eval-cache = lib.mkForce true; # Enable evaluation cache
      narinfo-cache-positive-ttl = lib.mkForce 3600; # Cache narinfos for 1h
      narinfo-cache-negative-ttl = lib.mkForce 60; # Retry missing narinfos after 1m
      fsync-metadata = lib.mkForce false; # Faster on SSDs
      connect-timeout = lib.mkForce 10; # 10s connection timeout
      max-substitution-jobs = lib.mkForce 128; # Parallel substitutions
      http-connections = lib.mkForce 128; # Parallel HTTP connections
      cores = lib.mkForce 0; # Use all CPU cores
      max-jobs = lib.mkForce "auto"; # Use all CPU cores
      keep-build-log = lib.mkForce false; # Don't keep build logs
      compress-build-log = lib.mkForce true; # Compress build logs
      require-sigs = lib.mkForce true; # Require signatures for substitutes
      allowed-users = lib.mkForce [
        "root"
        "@wheel"
      ]; # Only allow root and wheel
      trusted-users = lib.mkForce [
        "root"
        "@wheel"
      ]; # Only trust root and wheel
    };
  };

  boot = {
    # Boot verbosity and logging
    consoleLogLevel = lib.mkDefault 0; # Log all boot messages
    initrd.verbose = lib.mkDefault false; # Disable verbose initrd

    loader = {
      systemd-boot.enable = lib.mkDefault true; # Enable systemd-boot by default
      efi.canTouchEfiVariables = lib.mkDefault true; # Allow EFI variable modification
      efi.efiSysMountPoint = lib.mkForce "/boot"; # Enforce /boot as EFI mount point
    };

    plymouth = {
      enable = lib.mkDefault true; # Enable plymouth boot splash
      theme = lib.mkForce pkgs.plymouth-theme.name; # Enforce custom boot theme
      themePackages = lib.mkForce [ pkgs.plymouth-theme ]; # Enforce theme package
    };

    # Kernel parameters for security and auditing
    kernelParams = [
      "fips=1" # Enable FIPS mode
      "audit=1" # Enable auditing
      "audit_backlog_limit=8192" # Increase audit backlog
    ];

    kernel.sysctl = {
      "net.ipv4.tcp_syncookies" = "1"; # Enable TCP SYN cookies
      "kernel.kptr_restrict" = 1; # Restrict kernel pointer exposure
      "kernel.randomize_va_space" = 2; # Enable full ASLR
    };
  };

  # Harden kernel security by default
  security.lockKernelModules = lib.mkDefault true;
  security.protectKernelImage = lib.mkDefault true;
  security.unprivilegedUsernsClone = lib.mkDefault true;

  programs = {
    gnupg.agent.enable = lib.mkForce true; # Always enable GnuPG agent
    # Only start SSH agent if GNOME gcr-ssh-agent is disabled
    ssh.startAgent = lib.mkIf (config.services.gnome.gcr-ssh-agent.enable == false) true;
    deadman.enable = lib.mkDefault true; # Enable deadman switch by default
  };

  # Use mkDefault so users can extend or override default packages
  environment.defaultPackages = lib.mkDefault [ ];

  services = {
    dbus.enable = lib.mkForce true; # Always enable D-Bus system bus
    smartd.enable = lib.mkDefault true; # Enable SMART disk monitoring by default
    thermald.enable = lib.mkDefault true; # Enable thermal management by default
    upower.enable = lib.mkDefault true; # Enable power management by default
    fwupd.enable = lib.mkDefault true; # Enable firmware updates by default
    fstrim.enable = lib.mkDefault true; # Enable periodic SSD TRIM by default
  };

  home-manager = {
    useGlobalPkgs = lib.mkForce true; # Always use global pkgs for Home Manager
    backupFileExtension = lib.mkForce "backup"; # Set backup extension for Home Manager
    sharedModules = [
      self.inputs.base16.homeManagerModule # Base16 theming for Home Manager
      {
        inherit scheme;
        home = {
          stateVersion = lib.mkForce "25.11"; # Pin Home Manager state version
          enableNixpkgsReleaseCheck = lib.mkForce false; # Disable release check
        };
        programs = {
          bash.enable = lib.mkForce true; # Always enable bash
          info.enable = lib.mkForce true; # Always enable info
          hstr.enable = lib.mkForce true; # Always enable hstr
        };
      }
    ];
  };
}
