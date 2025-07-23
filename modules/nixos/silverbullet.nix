{ config, lib, hostname, ... }:

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = false;
    };
    services.nginx.virtualHosts."sb.${hostname}".locations."/".proxyPass = "http://${config.services.silverbullet.listenAddress}:${toString config.services.silverbullet.listenPort}";
    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details = {
        listen = {
          text = "${config.services.silverbullet.listenAddress}:${toString config.services.silverbullet.listenPort}";
        };
      };
    };
  };
}
