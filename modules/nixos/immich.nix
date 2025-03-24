{ config, lib, ... }:

let
  cfg = config.modules.services.immich;
in

with lib;

{
  options.modules.services.immich.enable = mkEnableOption "immich";

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      openFirewall = true;
    };
  };
}
