{ config, lib, hostname, ... }:

let
  virtualHost = "immich.${hostname}";
in

{
  config = lib.mkIf config.services.immich.enable {
    services.immich.host = "0.0.0.0";

    services.nginx = {
      enable = true;
      tailscaleAuth = {
        enable = true;
        virtualHosts = [ virtualHost ];
      };
      virtualHosts."${virtualHost}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString 2283}";
      };
    };

    topology.self.services.immich = {
      name = "Immich";
      details.listen.text = virtualHost;
    };
  };
}

