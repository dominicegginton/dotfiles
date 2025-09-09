{ config, lib, pkgs, ... }:

let
  cfg = config.services.xserver.desktopManager.gnome;
  serviceCfg = config.services.gnome;

  background-light = pkgs.nixos-artwork.wallpapers.simple-blue;
  background-dark = pkgs.nixos-artwork.wallpapers.simple-dark-gray;

  gsettings-desktop-schemas = pkgs.gnome.nixos-gsettings-overrides.override {
    inherit (cfg) extraGSettingsOverrides extraGSettingsOverridePackages favoriteAppsOverride;
    inherit flashbackEnabled background-dark background-light;
  };

  residence-background-info = pkgs.writeTextFile rec {
    name = "residence-background-info.xml";
    text = with config.scheme.withHashtag; ''
      <?xml version="1.0"?>
      <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
      <wallpapers>
        <wallpaper deleted="false">
          <name>Blobs</name>
          <filename>${background-light.gnomeFilePath}</filename>
          <filename-dark>${background-dark.gnomeFilePath}</filename-dark>
          <options>zoom</options>
          <shade_type>solid</shade_type>
          <pcolor>${blue}</pcolor>
          <scolor>${yellow}</scolor>
        </wallpaper>
      </wallpapers>
    '';
    destination = "/share/gnome-background-properties/residence.xml";
  };

  flashbackEnabled = cfg.flashback.enableMetacity || lib.length cfg.flashback.customSessions > 0;
in

{
  options.display.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.display.gnome.enable {
    hardware.graphics.enable = true;
    services.printing.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.systemPackages = with pkgs; [ gnome-console residence-background-info ];
    environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs nixos-background-info gnome-backgrounds ];

    networking.networkmanager.enable = true;
  };
}
