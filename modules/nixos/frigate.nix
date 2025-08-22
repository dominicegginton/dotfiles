{ config, lib, hostname, ... }:

{
  config = lib.mkIf config.services.frigate.enable {
    services.frigate = {
      hostname = "fg.${hostname}";
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
    topology.self.services.frigate = {
      name = "Frigate NVR";
      details.listen.text = config.services.frigate.hostname;
    };
  };
}
