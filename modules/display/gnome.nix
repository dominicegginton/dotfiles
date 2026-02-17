{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Prioritize nautilus by default when opening directories
  mimeAppsList = pkgs.writeTextFile {
    name = "gnome-mimeapps";
    destination = "/share/applications/mimeapps.list";
    text = ''
      [Default Applications]
      inode/directory=nautilus.desktop;org.gnome.Nautilus.desktop
    '';
  };

  # Create dconf settings bottom level attributes
  dconfSettings = name: settings: {
    settings = {
      name = settings;
    };
  };

  orgGnomeMutterSettings = dconfSettings "org/gnome/mutter" {
    experimental-features = [
      "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
      "kms-modifiers" # Allows changing display settings with keyboard shortcuts (e.g., Super+P)
      "auto-close-xwayland" # Automatically closes Xwayland sessions when not needed
      "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
      "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
    ];
  };

  # Gnome keybindings for window management
  orgGnomeDesktopWmKeybindingsSettings = dconfSettings "org/gnome/desktop/wm/keybindings" {
    close = [ "<Super><Shift>q" ];
  };

  # Gnome desktop background
  orgGnomeDesktopBackgroundSettings = dconfSettings "org/gnome/desktop/background" {
    picture-uri = "file://" + pkgs.background.backgroundImage;
    picture-uri-dark = "file://" + pkgs.background.darkBackgroundImage;
  };

  # Desktop notifications configuration
  orgGnomeDesktopNotificationsSettings = dconfSettings "org/gnome/desktop/notifications" {
    show-banners = true;
    show-in-lock-screen = false;
  };

  # Gnome shell interface settings
  orgGnomeDesktopInterfaceSettings = dconfSettings "org/gnome/desktop/interface" {
    enable-hot-corners = false;
    color-theme = "prefer-light";
  };

  # Touchpad configuration
  orgGnomeDesktopPeripheralsTouchpadSettings =
    dconfSettings "org/gnome/desktop/peripherals/touchpad"
      {
        click-method = "fingers";
        natural-scroll = true;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };

  # Privacy preserving defaults
  orgGnomeDesktopPrivacySettings = dconfSettings "org/gnome/desktop/privacy" {
    remember-recent-files = false;
    remove-old-temp-files = true;
    remove-old-trash-files = true;
    report-technical-problems = false;
    send-software-usage-stats = false;
    show-full-name-in-top-bar = true;
    usb-protection = true;
    usb-protection-level = "lockscreen";
  };

  # Lockscreen configuration
  orgGnomeDesktopLockscreenSettings = dconfSettings "org/gnome/desktop/lockscreen" {
    idle-activation-enabled = true;
    lock-delay = lib.gvariant.mkInt32 0;
    lock-enabled = true;
    logout-enabled = false;
    picture-uri = "file://" + pkgs.background.backgroundImage;
    restart-enabled = false;
    user-switch-enabled = false;
  };

  # Gnome Shell configuration
  orgGnomeShellSettings = dconfSettings "org/gnome/shell" {
    allow-extension-installation = false;
    enabled-extensions = [
      "rounded-window-corners@fxgn"
      "light-style@gnome-shell-extensions.gcampax.github.com"
    ];
    favorite-apps = [
      "org.gnome.Epiphany.desktop"
      "org.gnome.Nautilus.desktop"
      "org.gnome.Terminal.desktop"
    ];
  };

  orgGnomeTerminalLockdownSettings = dconfSettings "org/gnome/terminal/lockdown" {
    disable-user-switching = true;
    disable-user-administration = true;
  };

  # Default Gnome console
  orgGnomeConsoleSettings = dconfSettings "org/gnome/Console" {
    theme = "auto";
  };
in

with lib;

{
  options.display.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.display.gnome.enable {
    # Enable hardware support
    hardware.graphics.enable = mkDefault true;
    hardware.bluetooth.enable = mkDefault true;
    services.hardware.bolt.enable = mkDefault true;

    # Enable GDM display manager
    services.displayManager.gdm.enable = mkDefault true;

    # Enable required Gnome services and features
    i18n.inputMethod.enable = mkDefault true;
    i18n.inputMethod.type = mkDefault "ibus";
    programs.dconf.enable = mkDefault true;
    security.polkit.enable = mkDefault true;
    security.rtkit.enable = mkDefault true;
    services.pipewire.enable = mkDefault true;
    services.accounts-daemon.enable = mkDefault true;
    services.dleyna.enable = mkDefault true;
    services.power-profiles-daemon.enable = mkDefault true;
    services.gnome.at-spi2-core.enable = mkDefault true;
    services.gnome.evolution-data-server.enable = mkDefault true;
    services.gnome.gnome-keyring.enable = mkDefault true;
    services.gnome.gcr-ssh-agent.enable = mkDefault true;
    services.gnome.gnome-online-accounts.enable = mkDefault true;
    services.gnome.localsearch.enable = mkDefault true;
    services.gnome.tinysparql.enable = mkDefault true;
    services.udisks2.enable = mkDefault true;
    services.upower.enable = mkDefault true;
    services.libinput.enable = mkDefault true;

    # Enable XDG features
    xdg.mime.enable = mkDefault true;
    xdg.icons.enable = mkDefault true;
    xdg.portal.enable = mkDefault true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];

    # Gnome portals requires Gnome session
    xdg.portal.configPackages = mkDefault [ pkgs.gnome-session ];

    # Gnome relies on NetworkManager for network configuration
    networking.networkmanager.enable = mkDefault true;

    # Gnome Shell relies on D-Bus environment variables to be set for the session
    services.xserver.updateDbusEnvironment = mkDefault true;

    # Required for themes and backgrounds
    environment.pathsToLink = [ "/share" ];

    # Ensure Gnome Shell is available as a session option for the display manager
    services.desktopManager.gnome.sessionPath = [ pkgs.gnome-shell ];

    # Add mutter to udev packages to ensure it gets restarted when necessary
    services.udev.packages = with pkgs; [
      mutter
      gnome-settings-daemon
    ];

    # Append Gnome session and shell to system packages
    # ensuring they are available for the display manager
    # and session selection. xdg-user-dirs and xdg-user-dirs-gtk
    # are also appended to ensure user directories are created and
    # available in the session.
    systemd.packages = with pkgs; [
      gdm
      gnome-session
      gnome-shell
      xdg-user-dirs
      xdg-user-dirs-gtk
    ];

    # Enable required Gnome services
    services.colord.enable = mkDefault true;
    services.gnome.glib-networking.enable = mkDefault true;
    services.gnome.gnome-browser-connector.enable = mkDefault true;
    services.gnome.gnome-initial-setup.enable = mkDefault true;
    services.gnome.gnome-remote-desktop.enable = mkDefault true;
    services.gnome.gnome-settings-daemon.enable = mkDefault true;
    services.gnome.gnome-user-share.enable = mkDefault true;
    services.gnome.rygel.enable = mkDefault true;
    services.gnome.sushi.enable = mkDefault true;
    services.gvfs.enable = mkDefault true;
    services.avahi.enable = mkDefault true;
    services.orca.enable = mkDefault true;
    programs.seahorse.enable = mkDefault true;
    programs.gnome-disks.enable = mkDefault true;

    # Enable system-config-printer if printing is enabled, since Gnome's printer settings rely on it
    services.system-config-printer.enable = (lib.mkIf config.services.printing.enable (mkDefault true));

    # Enable geoclue2 for location service,
    # Gnome has its own geoclue agent
    services.geoclue2.enable = mkDefault true;
    services.geoclue2.enableDemoAgent = false;
    services.geoclue2.appConfig.gnome-datetime-panel = {
      isAllowed = true;
      isSystem = true;
    };
    services.geoclue2.appConfig.gnome-color-panel = {
      isAllowed = true;
      isSystem = true;
    };
    services.geoclue2.appConfig."org.gnome.Shell" = {
      isAllowed = true;
      isSystem = true;
    };

    # VTE shell integration for gnome-console
    programs.bash.vteIntegration = mkDefault true;
    programs.zsh.vteIntegration = mkDefault true;

    # Let nautilus find extensions
    environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

    # Override default mimeapps for nautilus
    environment.sessionVariables.XDG_DATA_DIRS = [ "${mimeAppsList}/share" ];

    # Font configuration
    fonts.enableDefaultPackages = lib.mkForce false;
    fonts.fontDir.enable = lib.mkForce true;
    fonts.packages = with pkgs; [
      adwaita-fonts
      font-manager
      noto-fonts-color-emoji
      ibm-plex
    ];
    fonts.fontconfig = {
      enable = lib.mkForce true;
      antialias = lib.mkForce true;
      hinting.autohint = lib.mkForce true;
      hinting.enable = lib.mkForce true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        serif = [ "Ibm Plex Serif" ];
        sansSerif = [ "Ibm Plex Sans" ];
        monospace = [
          "Ibm Plex Mono"
          "Noto Nerd Font Mono"
        ];
      };
    };

    # Configure dconf Gnome settings
    programs.dconf.profiles.user.databases = [
      orgGnomeMutterSettings
      orgGnomeDesktopWmKeybindingsSettings
      orgGnomeDesktopBackgroundSettings
      orgGnomeDesktopNotificationsSettings
      orgGnomeDesktopInterfaceSettings
      orgGnomeDesktopPeripheralsTouchpadSettings
      orgGnomeDesktopPrivacySettings
      orgGnomeDesktopLockscreenSettings
      orgGnomeShellSettings
      orgGnomeTerminalLockdownSettings
      orgGnomeConsoleSettings
    ];

    environment.systemPackages = with pkgs; [
      # Gnome Shell
      gnome-shell

      # Default Gnome Packages
      epiphany
      gnome-control-center
      gnome-bluetooth
      gnome-color-manager
      gnome-text-editor
      gnome-calculator
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-console
      gnome-contacts
      gnome-font-viewer
      gnome-weather
      loupe
      nautilus
      papers
      gnome-firmware
      lock
      resources
      glib
      gnome-menus
      gtk3.out # for gtk-launch program
      xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
      xdg-user-dirs-gtk # Used to create the default bookmarks

      # Background
      background

      # Icon Theme
      adwaita-icon-theme

      # Sound Theme as Gnome's default alert sound theme still inherits from it
      sound-theme-freedesktop

      # Gnome Shell Extensions
      gnome-shell-extensions
      gnomeExtensions.rounded-window-corners-reborn
      gnomeExtensions.dynamic-music-pill
    ];
  };
}
