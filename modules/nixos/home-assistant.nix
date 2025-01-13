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
        recorder.db_url = "postgresql://@/hass";
        homeassistant = {
          name = "Burbage";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          time_zone = "UTC";
        };
        zone = [
          {
            name = "Quorndon";
            latitude = "!secret quorndon_latitude";
            longitude = "!secret quorndon_longitude";
            radius = "100";
          }
        ];
        frontend = { themes = "!include_dir_merge_named themes"; };
        http = { };
        map = { };
        shopping_list = { };
        weather = { };
        feedreader.urls = [
          "https://nixos.org/blogs.xml"
        ];
      };
    };
    services.postgresql = {
      ensureDatabases = [ "hass" ];
      ensureUsers = [{ name = "hass"; ensureDBOwnership = true; }];
    };
  };
}
