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
            favorite-apps = [
              "org.gnome.Epiphany.desktop"
              "org.gnome.Nautilus.desktop"
              "org.gnome.Terminal.desktop"
            ];
          };
          "org/gnome/desktop/interface" = {
            enable-hot-corners = false;
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
