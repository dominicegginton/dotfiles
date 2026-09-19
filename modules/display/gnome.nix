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

  # Default favorite apps
  defaultFavoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'org.gnome.Epiphany.desktop', 'org.gnome.Geary.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Music.desktop', 'org.gnome.Nautilus.desktop' ]
  '';

  cfg = config.display.gnome;

  # Gnome settings overrides
  nixos-gsettings-desktop-schemas = pkgs.gnome.nixos-gsettings-overrides.override {
    inherit (cfg)
      extraGSettingsOverrides
      extraGSettingsOverridePackages
      favoriteAppsOverride
      ;
  };

  settingWrapper = settings: { inherit settings; };
  settings = name: settings: settingWrapper { "${name}" = settings; };

  orgGnomeMutterSettings = settings "org/gnome/mutter" {
    experimental-features = [
      "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
      "kms-modifiers" # Allows changing display settings with keyboard shortcuts (e.g., Super+P)
      "auto-close-xwayland" # Automatically closes Xwayland sessions when not needed
      "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
      "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
    ];
  };

  # Gnome keybindings for window management
  orgGnomeDesktopWmKeybindingsSettings = settings "org/gnome/desktop/wm/keybindings" {
    close = [ "<Super><Shift>q" ];
  };

  # Gnome desktop background settings
  orgGnomeDesktopBackgroundSettings = settings "org/gnome/desktop/background" {
    picture-uri = "file://" + pkgs.background.backgroundImage;
    picture-uri-dark = "file://" + pkgs.background.darkBackgroundImage;
  };

  # Desktop notifications configuration
  orgGnomeDesktopNotificationsSettings = settings "org/gnome/desktop/notifications" {
    show-banners = true;
    show-in-lock-screen = false;
  };

  # Gnome shell interface appearance
  orgGnomeDesktopInterfaceSettings = settings "org/gnome/desktop/interface" {
    enable-hot-corners = false;
    color-theme = "prefer-light";
  };

  # Touchpad configuration
  orgGnomeDesktopPeripheralsTouchpadSettings = settings "org/gnome/desktop/peripherals/touchpad" {
    click-method = "fingers";
    natural-scroll = true;
    tap-to-click = true;
    two-finger-scrolling-enabled = true;
  };

  # Privacy preserving defaults
  orgGnomeDesktopPrivacySettings = {
    locks = [
      "org/gnome/desktop/privacy/usb-protection"
      "org/gnome/desktop/privacy/usb-protection-level"
    ];
    settings = {
      "org/gnome/desktop/privacy" = {
        remember-recent-files = false;
        remove-old-temp-files = true;
        remove-old-trash-files = true;
        report-technical-problems = false;
        send-software-usage-stats = false;
        show-full-name-in-top-bar = true;
        # Disable GNOME USB protection so re-plugged USB devices (e.g. Yubikeys) are allowed
        # while the session is locked or at the lock screen. USB authorization is managed
        # explicitly via USBGuard instead.
        usb-protection = false;
      };
    };
  };

  orgGnomeDesktopPrivacySettingsGdm = {
    locks = [
      "org/gnome/desktop/privacy/usb-protection"
      "org/gnome/desktop/privacy/usb-protection-level"
    ];
    settings = {
      "org/gnome/desktop/privacy" = {
        # Disable GNOME USB protection in GDM greeter so Yubikeys plugged in at login can authenticate.
        usb-protection = false;
      };
    };
  };

  # Screensaver & lockscreen configuration
  orgGnomeDesktopLockscreenSettings = settings "org/gnome/desktop/screensaver" {
    idle-activation-enabled = true;
    lock-delay = lib.gvariant.mkInt32 0;
    lock-enabled = true;
    logout-enabled = false;
    picture-uri = "file://" + pkgs.background.backgroundImage;
    restart-enabled = false;
    user-switch-enabled = false;
  };

  inherit (cfg) extensions;

  uuid =
    ext:
    lib.attrByPath [ "extensionUuid" ] (lib.attrByPath [ "uuid" ] (lib.attrByPath [
      "passthru"
      "extensionUuid"
    ] null ext) ext) ext;

  extensionUuid = uuid;

  # Gnome Shell configuration
  orgGnomeShellSettings = settings "org/gnome/shell" {
    allow-extension-installation = false;
    development-tools = false;
    disable-extension-change = true;
    disable-user-extensions = true;
    enabled-extensions =
      if extensions == [ ] then
        lib.gvariant.mkEmptyArray lib.gvariant.type.string
      else
        lib.map extensionUuid extensions;
    favorite-apps = [
      "org.gnome.Epiphany.desktop"
      "org.gnome.Nautilus.desktop"
      "org.gnome.Terminal.desktop"
    ];
  };

  orgGnomeTerminalLockdownSettings = settings "org/gnome/terminal/lockdown" {
    disable-user-switching = true;
    disable-user-administration = true;
  };

  # Default Gnome console
  orgGnomeConsoleSettings = settings "org/gnome/Console" {
    theme = "auto";
  };
in

with lib;

{
  options.display.gnome = {
    enable = mkEnableOption "Gnome";

    favoriteAppsOverride = mkOption {
      internal = true; # this is messy
      default = defaultFavoriteAppsOverride;
      type = types.lines;
      example = literalExpression ''
        '''
          [org.gnome.shell]
          favorite-apps=[ 'firefox.desktop', 'org.gnome.Calendar.desktop' ]
        '''
      '';
      description = "List of desktop files to put as favorite apps into pkgs.gnome-shell. These need to be installed somehow globally.";
    };

    extraGSettingsOverrides = mkOption {
      default = "";
      type = types.lines;
      description = "Additional gsettings overrides.";
    };

    extraGSettingsOverridePackages = mkOption {
      default = [ ];
      type = types.listOf types.path;
      description = "List of packages for which gsettings are overridden.";
    };

    sessionPath = mkOption {
      default = [ ];
      type = types.listOf types.package;
      example = literalExpression "[ pkgs.gpaste ]";
      description = ''
        Additional list of packages to be added to the session search path.
        Useful for GNOME Shell extensions or GSettings-conditional autostart.

        Note that this should be a last resort; patching the package is preferred (see GPaste).
      '';
    };

    extensions = mkOption {
      default = with pkgs.gnomeExtensions; [
        rounded-window-corners-reborn
        solar-theme-switcher
      ];
      type = types.listOf types.package;
      description = "List of GNOME Shell extensions to install and enable.";
    };
  };

  config = mkIf cfg.enable {
    # Desktop environments require unprivileged user namespaces for sandboxing (e.g. bubblewrap/flatpak/browsers)
    boot.kernel.sysctl."user.max_user_namespaces" = lib.mkDefault 10000;

    system.nixos-generate-config.desktopConfiguration = [
      ''
        # Enable the GNOME Desktop Environment.
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;
      ''
    ];

    environment = {
      extraInit = ''
        ${lib.concatMapStrings (p: ''
          if [ -d "${p}/share/gsettings-schemas/${p.name}" ]; then
            export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${p}/share/gsettings-schemas/${p.name}
          fi

          if [ -d "${p}/lib/girepository-1.0" ]; then
            export GI_TYPELIB_PATH=$GI_TYPELIB_PATH''${GI_TYPELIB_PATH:+:}${p}/lib/girepository-1.0
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${p}/lib
          fi
        '') config.display.gnome.sessionPath}
      '';

      sessionVariables = {
        NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
        # Let nautilus find extensions
        NAUTILUS_4_EXTENSION_DIR = lib.mkForce "${config.system.path}/lib/nautilus/extensions-4";
        # Override default mimeapps for nautilus
        XDG_DATA_DIRS = lib.mkForce [ "${mimeAppsList}/share" ];
      };

      # Required for themes and backgrounds
      pathsToLink = [ "/share" ];
    };

    # Enable hardware support
    hardware.graphics.enable = mkDefault true;
    hardware.bluetooth.enable = mkDefault true;

    # Enable required Gnome services and features
    i18n.inputMethod.enable = mkDefault true;
    i18n.inputMethod.type = mkDefault "ibus";

    security.polkit.enable = mkDefault true;
    security.rtkit.enable = mkDefault true;

    # Gnome relies on NetworkManager for network configuration
    networking.networkmanager.enable = mkDefault true;

    services = {
      displayManager = {
        sessionPackages = [ pkgs.gnome-session.sessions ];
        gdm.enable = mkDefault true;
      };

      hardware.bolt.enable = mkDefault true;

      # Enable GNOME Desktop Environment
      desktopManager.gnome = {
        enable = mkDefault true;
        sessionPath = [ pkgs.gnome-shell ];
      };

      pipewire.enable = mkDefault true;
      accounts-daemon.enable = mkDefault true;
      dleyna.enable = mkDefault true;
      power-profiles-daemon.enable = mkDefault true;
      gnome = {
        at-spi2-core.enable = mkDefault true;
        evolution-data-server.enable = mkDefault true;
        gnome-keyring.enable = mkDefault true;
        gcr-ssh-agent.enable = mkDefault true;
        gnome-online-accounts.enable = mkDefault true;
        localsearch.enable = mkDefault true;
        tinysparql.enable = mkDefault true;
        glib-networking.enable = mkForce true;
        gnome-browser-connector.enable = mkForce true;
        gnome-initial-setup.enable = mkDefault true;
        gnome-remote-desktop.enable = mkDefault true;
        gnome-settings-daemon.enable = mkDefault true;
        gnome-user-share.enable = mkDefault true;
        rygel.enable = mkDefault true;
        sushi.enable = mkDefault true;
      };
      udisks2.enable = mkDefault true;
      upower.enable = mkDefault true;
      libinput.enable = mkDefault true;

      # Gnome Shell relies on D-Bus environment variables to be set for the session
      xserver.updateDbusEnvironment = mkDefault true;

      # Add mutter to udev packages to ensure it gets restarted when necessary
      udev.packages = with pkgs; [
        mutter
        gnome-settings-daemon
        gnome-bluetooth
      ];

      # Enable required Gnome services
      colord.enable = mkForce true;
      gvfs.enable = mkDefault true;
      avahi.enable = mkDefault true;
      orca.enable = mkDefault true;

      # Enable system-config-printer if printing is enabled, since Gnome's printer settings rely on it
      system-config-printer.enable = mkIf config.services.printing.enable (mkDefault true);

      # Enable geoclue2 for location service,
      # Gnome has its own geoclue agent
      geoclue2 = {
        enable = mkDefault true;
        enableDemoAgent = lib.mkIf config.services.geoclue2.enable (mkForce false);
        appConfig = lib.mkIf config.services.geoclue2.enable {
          gnome-datetime-panel = lib.mkForce {
            isAllowed = true;
            isSystem = true;
          };

          gnome-color-panel = lib.mkForce {
            isAllowed = true;
            isSystem = true;
          };

          "org.gnome.Shell" = lib.mkForce {
            isAllowed = true;
            isSystem = true;
          };
        };
      };
    };

    programs = {
      dconf.enable = mkDefault true;
      seahorse.enable = mkDefault true;
      gnome-disks.enable = mkDefault true;
    };

    # Enable XDG features
    xdg = {
      mime.enable = mkDefault true;
      icons.enable = mkDefault true;
      portal = {
        enable = mkDefault true;

        # Gnome portals requires Gnome session
        configPackages = mkDefault [ pkgs.gnome-session ];
      };
    };

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

    # Font Definitions
    fonts = {
      enableDefaultPackages = mkForce false;
      fontDir.enable = mkForce true;
      packages = with pkgs; [
        font-manager # Font Manager Application
        adwaita-fonts # Default Gnome Fonts
        ibm-plex # IBM Plex Fonts
        nerd-fonts.blex-mono # Nerd Font Mono
      ];
      fontconfig = {
        enable = mkForce true;
        antialias = mkForce true;
        hinting.autohint = mkForce true;
        hinting.enable = mkForce true;
        defaultFonts = {
          emoji = [ "Nerd Font Emoji" ];
          serif = [ "Ibm Plex Serif" ];
          sansSerif = [ "Ibm Plex Sans" ];
          monospace = [
            "Ibm Plex Mono"
            "Nerd Font Mono"
          ];
        };
      };
    };

    # Configure dconf Gnome settings
    programs.dconf.profiles.user.databases = with lib.gvariant; [
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

    # Configure dconf GDM greeter settings
    programs.dconf.profiles.gdm.databases = with lib.gvariant; [
      orgGnomeDesktopPrivacySettingsGdm
    ];

    # Firefox Web Browser
    programs.firefox.enable = mkDefault true;

    environment.systemPackages =
      with pkgs;
      [
        adwaita-icon-theme # Icon Theme - Required by Gnome Application
        sound-theme-freedesktop # Sound Theme - Gnome's default alert sound theme still inherits from it
        glib # GLib Library - Required by Gnome Applications
        gtk3.out # GTK3 Library - Required by gtk-launch program
        xdg-user-dirs # Updates User Directories
        xdg-user-dirs-gtk # Updates User Directories - GTK Integration
        gnome-shell # Shell
        gnome-menus # Gnome Menus
        background # Background Definition
        epiphany # Web Browser
        gnome-control-center # Control Center
        gnome-bluetooth # Bluetooth Settings - Required by Gnome Control Center
        gnome-color-manager # Color Management - Required by Gnome Control Center
        gnome-text-editor # Text Editor Applet
        gnome-calculator # Calculator Applet
        gnome-calendar # Calendar Applet
        gnome-characters # Characters Applet
        gnome-clocks # Clocks and Alarms Applet
        gnome-console # Console
        gnome-contacts # Contacts Applet
        gnome-font-viewer # Font Viewer Applet
        gnome-weather # Weather Applet
        loupe # Magnifier Applet
        nautilus # File Manager
        papers # Papers Applet
        gnome-firmware # Firmware Updater Applet
        lock # Encrypt / Decrypt Applet
        resources # System Monitor
      ]

      # Gnome Extension
      ++ extensions

      # Session Path Packages
      ++ config.display.gnome.sessionPath;
  };
}
