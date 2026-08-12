{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:

rec {
  imports = [
    # Core hardware detection and VM support
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"

    # Boot modules
    ./boot.nix

    # Nix configuration
    ./nix.nix

    # System-level configurations and branding
    ./system.nix

    # Home Manager settings and shared modules
    ./home-manager.nix

    # Console and display environments
    ./console.nix
    ./display/gnome.nix
    ./display/niri.nix
    ./display/driftwm.nix

    # Environment modules
    ./environment.nix
    ./environment/account.nix
    ./environment/issue.nix
    ./environment/login.nix
    ./environment/packages.nix

    # Hardware modules
    ./hardware/bluetooth.nix
    ./hardware/cpu.nix

    # Networking stack
    ./networking.nix

    # Programs
    ./programs/alacritty.nix
    ./programs/chromium.nix
    ./programs/dconf.nix
    ./programs/firefox.nix
    ./programs/sherlock-launcher.nix
    ./programs/steam.nix

    # Secrets management
    ./secrets.nix

    # Security
    ./security/acme.nix
    ./security/apparmor.nix
    ./security/pam.nix
    ./security/polkit.nix
    ./security/pwquality.nix
    ./security/run0.nix
    ./security/sudo.nix
    ./security/systemd.nix
    ./security/tpm2.nix
    ./security/yubikey.nix

    # Service
    ./services/beszel.nix
    ./services/bitmagnet.nix
    ./services/calmav.nix
    ./services/displaymanager.nix
    # ./services/dit0.nix # Disabled: experimental LDAP server
    ./services/fail2ban.nix
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
    ./services/onlyoffice-documentserver.nix
    ./services/oauth2-proxy.nix
    ./services/timesyncd.nix
    ./services/transmission.nix
    ./services/tsidp.nix
    ./services/usbguard.nix

    # User
    ./users/ldap.nix
    ./users/sssd.nix
    ./users/root.nix

    # Virtualisation
    ./virtualisation/docker.nix
    ./virtualisation/vm-variant.nix
    ./virtualisation/waydroid.nix
    ./virtualisation/wsl.nix
  ];

  # System-wide color scheme (used by Home Manager and theming modules)
  scheme = lib.mkForce "${pkgs.theme}/residence-theme.yaml";

  # Localization settings
  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";

  programs = {
    gnupg.agent = {
      enable = lib.mkForce true; # Always enable GnuPG agent
      enableSSHSupport = lib.mkDefault true; # Enable SSH support through GnuPG agent
      pinentryPackage = lib.mkDefault (
        if (config.display.gnome.enable || config.display.niri.enable || config.display.driftwm.enable) then
          pkgs.pinentry-gnome3
        else
          pkgs.pinentry-curses
      );
    };
    # Disable regular SSH agent to avoid conflicts with GnuPG SSH support
    ssh.startAgent = lib.mkForce false;
    deadman.enable = lib.mkDefault true; # Enable deadman switch by default
  };

  services = {
    beszel.enable = lib.mkDefault true; # Enable Beszel service
    dbus.enable = lib.mkForce true; # Always enable D-Bus system bus
    smartd.enable = lib.mkDefault true; # Enable SMART disk monitoring by default
    thermald.enable = lib.mkDefault true; # Enable thermal management by default
    upower.enable = lib.mkDefault true; # Enable power management by default
    fwupd.enable = lib.mkDefault true; # Enable firmware updates by default
    fstrim.enable = lib.mkDefault true; # Enable periodic SSD TRIM by default
  };

  environment.defaultPackages = lib.mkDefault [ ];
}
