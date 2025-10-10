{ config, lib, pkgs, ... }:

let
  mimeAppsList = pkgs.writeTextFile {
    name = "gnome-mimeapps";
    destination = "/share/applications/mimeapps.list";
    text = ''
      [Default Applications]
      inode/directory=nautilus.desktop;org.gnome.Nautilus.desktop
    '';
  };

  defaultFavoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'org.gnome.Epiphany.desktop', 'org.gnome.Geary.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Music.desktop', 'org.gnome.Nautilus.desktop' ]
  '';

  gsettings-desktop-schemas = pkgs.gnome.nixos-gsettings-overrides.override {
    inherit (config.services.xserver.desktopManager.gnome) extraGSettingsOverrides extraGSettingsOverridePackages favoriteAppsOverride;
  };

  destination = "/share/gnome-background-properties/residence.xml";
in

{
  options.display.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.display.gnome.enable {
    hardware.graphics.enable = true;
    networking.networkmanager.enable = true;
    programs.firefox.enable = true;
    services = {
      printing.enable = true;
      pipewire.enable = true;
      tlp.batteryThreshold.enable = lib.mkDefault false;
      udev.packages = [ pkgs.gnome-settings-daemon ];
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
      gnome = {
        core-shell.enable = lib.mkDefault true;
        core-apps.enable = lib.mkDefault true;
      };
    };
    environment = {
      sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
        gnome-backgrounds
        gnome-text-editor
        yelp
      ];
      systemPackages = with pkgs; with gnomeExtensions; [
        background
        resources
        status-icons
        pano
      ];
    };
  };
}
