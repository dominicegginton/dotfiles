{ config, lib, pkgs, ... }:

{
  config.services.home-assistant = lib.mkIf config.services.home-assistant.enable {
    package = pkgs.home-assistant;
    openFirewall = true;
    lovelaceConfigWritable = true;
    configWritable = true;
    config = {
      lovelace.mode = "storage";
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "Europe/London";
        temperature_unit = "C";
      };
      mobile_app = { };
      history = { };
    };
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
    ];
  };
}
