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
        "auth"
        "api"
        "date"
        "datetime"
        "analytics"
        "mobile_app"
        "shopping_list"
        "hue"
        "history"
        "sun"
        "androidtv"
        "androidtv_remote"
        "google"
        "google_assistant"
        "google_assistant_sdk"
        "google_cloud"
        "google_generative_ai_conversation"
        "google_mail"
        "google_maps"
        "google_photos"
        "google_pubsub"
        "google_sheets"
        "google_tasks"
        "google_translate"
        "google_travel_timei"
        "met"
        "tailscale"
        "unifi"
      ];
    };
  };
}
