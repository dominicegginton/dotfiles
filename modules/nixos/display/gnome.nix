{ config, lib, pkgs, ... }:

let
  residence-background-info = pkgs.writeTextFile rec {
    name = "residence-background-info.xml";
    text = with config.scheme.withHashtag; ''
      <?xml version="1.0"?>
      <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
      <wallpapers>
        <wallpaper deleted="false">
          <name>Blobs</name>
          <filename>${pkgs.nixos-artwork.wallpapers.simple-blue.gnomeFilePath}</filename>
          <filename-dark>${pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath}</filename-dark>
          <options>zoom</options>
          <shade_type>solid</shade_type>
          <pcolor>${blue}</pcolor>
          <scolor>${yellow}</scolor>
        </wallpaper>
      </wallpapers>
    '';
    destination = "/share/gnome-background-properties/residence.xml";
  };
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
      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
        gnome-backgrounds
        gnome-text-editor
        yelp
      ];
      systemPackages = with pkgs; [
        residence-background-info
        resources
      ];
    };
  };
}
