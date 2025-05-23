{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.unifi;
  allowedRules = {
    allowedTCPPorts = [
      8080 # Port for UAP to inform controller.
      8880 # Port used for HTTP portal redirection.
      8843 # Port used for HTTPS portal redirection.
      8443 # Port used for application GUI/API as seen in a web browser.
      6789 # Port for UniFi mobile speed test.
    ];
    allowedUDPPorts = [
      3478 # UDP port used for STUN.
      1900 # Port used for "Make application discoverable on L2 network" in the UniFi Network settings.
      10001 # Port used for device discovery.
    ];
  };
in

with lib;

{
  options.modules.services.unifi.enable = mkEnableOption "unifi";

  config = mkIf cfg.enable {
    services.unifi.enable = true;
    services.unifi.openFirewall = true;
    services.unifi.unifiPackage = pkgs.unifi;
    services.unifi.mongodbPackage = pkgs.mongodb-7_0;
    networking.firewall.allowedTCPPorts = allowedRules.allowedTCPPorts;
    networking.firewall.allowedUDPPorts = allowedRules.allowedUDPPorts;
  };
}
