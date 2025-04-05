{ config, lib, hostname, tailnet, ... }:

let
  cfg = config.modules.services.frigate;
in

with lib;

{
  options.modules.services.frigate.enable = mkEnableOption "frigate";

  config = mkIf cfg.enable {
    services.frigate = {
      hostname = "frigate.${hostname}.${tailnet}";
      enable = true;
      settings.auth.enabled = false;
      settings.tls.enabled = false;
      settings.cameras = {
        "front".ffmpeg.inputs = [{ path = "rtsp://frigate:frigate@192.168.1.250"; roles = [ ]; }];
      };
    };

    topology.self.services.frigate = {
      name = "Frigate";
      details = {
        listen = {
          text = "frigate.${hostname}";
        };
      };
    };
  };
}
