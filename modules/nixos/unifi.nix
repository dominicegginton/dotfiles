{ lib, config, pkgs, hostname, ... }:

{
  config = lib.mkIf config.services.unifi.enable {
    services.unifi = {
      unifiPackage = pkgs.unifi;
      mongodbPackage = pkgs.mongodb-7_0;
    };
    networking.firewall = {
      allowedTCPPorts = [
        8080 # UAP inform service.
        6789 # Mobile speed test service.
      ];
      allowedUDPPorts = [
        3478 # UDP for STUN and TURN.
        10001 # UDP for device discovery. 
      ];
    };
    services.nginx.virtualHosts."unifi.${hostname}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8443";
        proxyWebsockets = true;
      };
    };
    # security.acme.certs."unifi.${hostname}" = {
    #   email = "admin@${hostname}";
    #   extraDomains = [ "unifi.${hostname}" ];
    # };
    topology.self.services.unifi = {
      name = "Unifi";
      icon = ./../../assets/unifi.svg;
      details.listen.text = "unifi.${hostname}";
    };
  };
}
