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
      systemPackages = with pkgs; with gnomeExtensions; [
        background
        resources
        status-icons
        pano
        night-theme-switcher
        caffeine
        tailscale-status
      ];
    };
  };
}
