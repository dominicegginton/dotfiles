{ config, lib, hostname, ... }:

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
      settings.cameras = {
        "foo" = {
          ffmpeg.inputs = [{
            path = "rtsp://192.168.123.108:8554/unicast";
            roles = [ "detect" ];
          }];
        };
      };
    };
  };
}
