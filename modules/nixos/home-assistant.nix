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
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [ mushroom advanced-camera-card ];
    customComponents = with pkgs.home-assistant-custom-components; [ frigate ];



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

      "unifi"
      "monzo"
      "metoffice"
      "cast"
      "rest"
      "thread"
      "threshold"
      "time"
      "time_date"
      "timer"
      "tmb"
      "tod"
      "todo"

      "google_assistant"
      "google_assistant_sdk"
      "google_cloud"
      "google_drive"
      "google_gemini"
      "google_generative_ai_conversation"
      "google_mail"
      "google_maps"
      "google_photos"
      "google_pubsub"
      "google_sheets"
      "google_tasks"
      "google_translate"
      "google_travel_time"
    ];
  };
}
