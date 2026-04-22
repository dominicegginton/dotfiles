{
  config,
  lib,
  pkgs,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.home-assistant.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services.home-assistant = {
      package = pkgs.home-assistant;
      openFirewall = lib.mkDefault true;
      lovelaceConfigWritable = true;
      configWritable = true;
      config = {
        lovelace.mode = "storage";
        frontend.themes = "!include_dir_merge_named themes";
        homeassistant = {
          name = "Ribble";
          unit_system = "metric";
          time_zone = "Europe/London";
          temperature_unit = "C";
        };
        default_config = { };
        mobile_app = { };
        history = { };
        http = {
          server_host = [ "0.0.0.0" ];
          server_port = 8123;
        };
      };
      customComponents = with pkgs.home-assistant-custom-components; [
        adaptive_lighting
        frigate
        waste_collection_schedule
      ];
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
        "metoffice"
        "cast"
        "rest"
        "thread"
        "threshold"
        "time"
        "time_date"
        "timer"
        "tod"
      ];
    };

    services.tailscale.serve = {
      enable = lib.mkDefault true;
      services."home-assistant".endpoints."tcp:80" =
        lib.mkDefault "http://127.0.0.1:${toString config.services.home-assistant.config.http.server-port}";
    };

    topology.self.services.home-assistant = {
      details.listen.text = "http://home-assistant.${tailnet}";
    };
  };
}
