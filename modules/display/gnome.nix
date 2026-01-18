{ config, lib, pkgs, ... }:

{
  options.display.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.display.gnome.enable {
    hardware.graphics.enable = lib.mkDefault true;

    networking.networkmanager.enable = true;

    services = {
      pipewire.enable = true;
      power-profiles-daemon.enable = true;
      udev.packages = [ pkgs.gnome-settings-daemon ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      gnome = {
        core-shell.enable = true;
        core-apps.enable = true;
      };
    };

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    fonts = {
      enableDefaultPackages = lib.mkForce false;
      packages = with pkgs; [ noto-fonts-color-emoji ];
      fontDir.enable = lib.mkForce true;
      fontconfig = {
        enable = lib.mkForce true;
        antialias = lib.mkForce true;
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        hinting.autohint = lib.mkForce true;
        hinting.enable = lib.mkForce true;
      };
    };

    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
              "kms-modifiers" # Allows changing display settings with keyboard shortcuts (e.g., Super+P)
              "auto-close-xwayland" # Automatically closes Xwayland sessions when not needed
              "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
              "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
            ];
          };
        };
      }
      {
        settings = {
          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super><Shift>q" ];
          };
          "org/gnome/desktop/background" = {
            picture-uri = "file://" + pkgs.background.backgroundImage;
            picture-uri-dark = "file://" + pkgs.background.darkBackgroundImage;
          };
          "org/gnome/shell" = {
            allow-extension-installation = false;
            favorite-apps = [
              "org.gnome.Epiphany.desktop"
              "org.gnome.Nautilus.desktop"
              "org.gnome.Terminal.desktop"
            ];
          };
          "org/gnome/desktop/interface" = {
            enable-hot-corners = false;
          };
          "org/gnome/desktop/notifications" = {
            show-banners = true;
            show-in-lock-screen = false;
          };
          "org/gnome/desktop/peripherals/touchpad" = {
            click-method = "fingers";
            natural-scroll = true;
            tap-to-click = true;
            two-finger-scrolling-enabled = true;
          };
          "org/gnome/desktop/privacy" = {
            remember-recent-files = false;
            remove-old-temp-files = true;
            remove-old-trash-files = true;
            report-technical-problems = false;
            send-software-usage-stats = false;
            show-full-name-in-top-bar = true;
            usb-protection = true;
            usb-protection-level = "lockscreen";
          };
          "org/gnome/desktop/lockscreen" = {
            idle-activation-enabled = true;
            lock-delay = lib.gvariant.mkInt32 0;
            lock-enabled = true;
            logout-enabled = false;
            picture-uri = "file://" + pkgs.background.backgroundImage;
            restart-enabled = false;
            user-switch-enabled = false;
          };
          "org/gnome/terminal/lockdown" = {
            disable-user-switching = true;
            disable-user-administration = true;
          };
          "org/gnome/Console" = {
            theme = "auto";
          };
        };
      }
    ];

    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
        gnome-backgrounds
        gnome-text-editor
        gnome-connections
        gnome-music
        yelp
        geary
        gnome-system-monitor
        gnome-disk-utility
        baobab
        gnome-software
        simple-scan
      ];
      systemPackages = with pkgs; with gnomeExtensions; [
        background
        mission-center
        gnome-firmware
        lock
      ];
    };
  };
}
