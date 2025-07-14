{ config, lib, pkgs, hostname, tailnet, ... }:

{
  config = lib.mkIf config.services.frigate.enable {
    services.frigate = {
      hostname = "${hostname}.${tailnet}";
      settings = {
        auth.enabled = false;
        motion.enabled = true;
        record.enabled = true;
        snapshots.enabled = true;
        detect = {
          enabled = true;
          fps = 5;
        };
      };
    };

    services.mosquitto.enable = true;
  };
}

