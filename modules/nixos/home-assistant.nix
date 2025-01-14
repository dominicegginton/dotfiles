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
      package = (pkgs.home-assistant.override { extraPackages = ps: [ ps.psycopg2 ]; });
      openFirewall = true;
      config = {
        shopping_list = { };
        weather = { };
        http = { };
        lovelace.mode = "storage";
        lovelaceConfigWritable = true;
        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          time_zone = "Europe/London";
          temperature_unit = "C";
        };
        frontend = { themes = "!include_dir_merge_named themes"; };
        recorder.db_url = "postgresql://@/hass";
        feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      };
      extraComponents = [
        "analytics"
        "default_config"
        "shopping_list"
        "weather"
        "unifi"
        "hue"
        "reolink"
      ];
    };
    services.postgresql = {
      ensureDatabases = [ "hass" ];
      ensureUsers = [{ name = "hass"; ensureDBOwnership = true; }];
    };
  };
}
