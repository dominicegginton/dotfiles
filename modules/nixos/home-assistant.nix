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
        "analytics"
        "mobile_app"
        "shopping_list"
        "hue"
        "history"
        "sun"
        "google"
        "google_assistant"
        "google_translate"
        "met"
        "tailscale"
      ];
    };
  };
}
