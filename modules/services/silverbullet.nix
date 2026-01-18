{ config, lib, hostname, ... }:

let
  virtualHost = "sb.${hostname}";
in

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = false;
    };

    services.nginx = {
      enable = true;
      tailscaleAuth = {
        enable = true;
        virtualHosts = [ virtualHost ];
      };
      virtualHosts."${virtualHost}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${config.services.silverbullet.listenAddress}:${toString config.services.silverbullet.listenPort}";
      };
    };

    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = virtualHost;
    };
  };
}
