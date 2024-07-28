{ config, lib, ... }:

let
  cfg = config.modules.services.syncthing;
in

with lib;

{
  options.modules.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      group = "users";
      guiAddress = "0.0.0.0:8384";
    };

    networking.firewall.allowedTCPPorts = [ 22000 ]; # tcp
    networking.firewall.allowedUDPPorts = [ 22000 ]; # quic
  };
}
