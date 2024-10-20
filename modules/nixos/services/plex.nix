{ config, lib, ... }:

let
  cfg = config.modules.services.plex;
in

with lib;

{
  options.modules.services.plex.enable = mkEnableOption "plex";

  config = mkIf cfg.enable {
    services.plex.enable = true;
    services.plex.openFirewall = true;
  };
}
