{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.services.home-assistant;
in

{
  options.modules.services.home-assistant.enable = mkEnableOption "home assistant";

  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      package = pkgs.home-assistant;
      openFirewall = true;
      lovelaceConfigWritable = true;
      config = {
        lovelace.mode = "storage";
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "Europe/London";
          temperature_unit = "C";
        };
        frontend = { themes = "!include_dir_merge_named themes"; };
        feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      };
      extraComponents = [
        "default_config"
        "date"
        "datetime"
        "browser" # Open URLs on host machine.
        "caldav" # Calendar.
        "camera" # IP camera support.
        "cast" # For Google/Chrome casting.
        "configurator" # Can request information from user.
        "dlna_dms" # DLNA streaming support.
        "ffmpeg" # FFmpg processing.
        "flux" # Adjust lighting based on sun.
        "sun"
        "moon"
        "homekit" # For controlling Home Assistant from the Apple Home app.
        "hue" # Philips Hue support.
        "jellyfin" # Media server.
        "keyboard" # Support keyboard devices.
        "kodi" # Media player.
        "matter" # Beta Matter and Thread support.
        "media_player" # Interacts with various media players.
        "rest_command" # Call REST APIs.
        "mobile_app"
        "history"
        "tailscale" # Tailscale support.
      ];
    };
  };
}
