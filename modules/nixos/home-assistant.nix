{ config, lib, pkgs, ... }:

{
  config.services.home-assistant = lib.mkIf config.services.home-assistant.enable {
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
      "default_config" # Default configuration for Home Assistant.
      "date" # Date support.
      "datetime" # Date and time support.
      "caldav" # Calendar.
      "camera" # IP camera support.
      "cast" # For Google/Chrome casting.
      "configurator" # Can request information from user.
      "dlna_dms" # DLNA streaming support.
      "ffmpeg" # FFmpeg support for media processing.
      "flux" # Adjust lighting based on sun.
      "sun" # Sun position.
      "moon" # Moon position.
      "homekit" # For controlling Home Assistant from the Apple Home app.
      "hue" # Philips Hue support.
      "jellyfin" # Media server.
      "keyboard" # Support keyboard devices.
      "kodi" # Media player.
      "matter" # Beta Matter and Thread support.
      "media_player" # Interacts with various media players.
      "rest_command" # Call REST APIs.
      "mobile_app" # Mobile app support.
      "history" # History of events.
    ];
  };
}
