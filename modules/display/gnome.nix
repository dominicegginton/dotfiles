{ config, lib, pkgs, ... }:

{
  options.display.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.display.gnome.enable {
    hardware.graphics.enable = true;
    networking.networkmanager.enable = true;
    services = {
      printing.enable = true;
      pipewire.enable = true;
      power-profiles-daemon.enable = false;
      udev.packages = [ pkgs.gnome-settings-daemon ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      flatpak.enable = true;
      gnome = {
        core-shell.enable = lib.mkDefault true;
        core-apps.enable = lib.mkDefault true;
      };
    };
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        antialias = true;
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        hinting.autohint = true;
        hinting.enable = true;
      };
      packages = with pkgs; [ noto-fonts-color-emoji ];
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
        gnome-software
      ];
      systemPackages = with pkgs; with gnomeExtensions; [
        background
        resources
        gnome-firmware
        dconf-editor
        overskride
        lock
        fragments
        delfin
      ];
    };
  };
}
