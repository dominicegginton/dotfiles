{ config, lib, ... }:

with lib;

let
  cfg = config.modules.services.home-assistant;
in

{
  options.modules.services.home-assistant.enable = mkEnableOption "home assistant";

  config = mkIf cfg.enable {
    services.home-assistant.enable = true;
    services.home-assistant.openFirewall = true;
    services.home-assistant.config = {
      homeassistant = {
        name = "Quarndon";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "UTC";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = { };
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };
  };
}
