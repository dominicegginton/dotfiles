{ config, lib, pkgs, ... }:

{
  config.services.home-assistant = lib.mkIf config.services.home-assistant.enable {
    package = pkgs.home-assistant;
    openFirewall = true;
    lovelaceConfigWritable = true;
    configWritable = true;
    config = {
      lovelace.mode = "storage";
      frontend.themes = "!include_dir_merge_named themes";
      homeassistant = {
        name = "Quardon";
        unit_system = "metric";
        time_zone = "Europe/London";
        temperature_unit = "C";
      };
      default_config = { };
      mobile_app = { };
      history = { };
      http = { };
    };
    customComponents = with pkgs.home-assistant-custom-components; [ frigate ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      advanced-camera-card
      bubble-card
      card-mod
      clock-weather-card
      mini-graph-card
      mushroom
    ];
    extraComponents = [
      "default_config"
      "esphome"
      "my"
      "shopping_list"
      "wled"
      "history"
      "met"
      "date"
      "datetime"
      "caldav"
      "configurator"
      "flux"
      "sun"
      "moon"
      "hue"
      "matter"
      "keyboard"
      "media_player"
      "rest_command"
      "mobile_app"
      "media_source"
      "mqtt"
      "metoffice"
      "cast"
      "rest"
      "thread"
      "threshold"
      "time"
      "time_date"
      "timer"
      "tod"
      "todo"
      "unifi"
      "monzo"
    ];
  };
}
