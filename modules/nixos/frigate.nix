{ config, lib, hostname, tailnet, ... }:

let
  cfg = config.modules.services.frigate;
in

with lib;

{
  options.modules.services.frigate.enable = mkEnableOption "frigate";

  config = mkIf cfg.enable {
    services.frigate = {
      inherit hostname;
      enable = true;
      settings.auth.enabled = false;
      settings.tls.enabled = false;
      settings.cameras = {
        "front".ffmpeg.inputs = [{ path = "rtsp://frigate:frigate@192.168.1.250"; roles = [ ]; }];
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      tailscaleAuth.enable = true;
      tailscaleAuth.virtualHosts = [ "frigate.${hostname}" ];
      virtualHosts."frigate.${hostname}" = {
        locations."/".proxyPass = "http://127.0.0.1:8971";
      };
    };
    topology.self.services.homepage-dashboard = {
      name = "Homepage Dashboard";
      details = {
        listen = {
          text = "dash.${hostname}";
        };
      };
    };
  };
}
