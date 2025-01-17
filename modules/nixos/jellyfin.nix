{ config, lib, ... }:

let
  cfg = config.modules.services.jellyfin;
in

with lib;

{
  options.modules.services.jellyfin = {
    enable = mkEnableOption "jellyfin";
    dataDir = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      dataDir = cfg.dataDir;
    };
  };
}
