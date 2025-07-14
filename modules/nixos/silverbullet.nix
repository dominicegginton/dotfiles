{ config, lib, pkgs, hostname, tailnet, ... }:

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = true;
    };
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

