{ config, lib, hostname, ... }:

{
  options.services.silverbullet.hostname = lib.mkOption {
    type = lib.types.str;
    default = "sb.${hostname}";
    description = "The hostname to use for Silverbullet.";
  };
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = false;
    };
    services.nginx.virtualHosts."${config.services.silverbullet.hostname}" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://${config.services.silverbullet.listenAddress}:${toString config.services.silverbullet.listenPort}";
    };
    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = config.services.silverbullet.hostname; 
    };
  };
}
