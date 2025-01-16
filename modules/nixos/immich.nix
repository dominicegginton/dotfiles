{ config, lib, ... }:

let
  cfg = config.modules.services.immich;
  allowedRules = {
    allowedTCPPorts = [ 2283 ];
    allowedUDPPorts = [ ];
  };
in

with lib;

{
  options.modules.services.immich.enable = mkEnableOption "immich";

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      port = 2283;
      openFirewall = true;
    };
    networking.firewall.allowedTCPPorts = allowedRules.allowedTCPPorts;
    networking.firewall.allowedUDPPorts = allowedRules.allowedUDPPorts;
  };
}
