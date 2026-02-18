{
  config,
  lib,
  hostname,
  ...
}:

{
  config = lib.mkIf config.services.frigate.enable {
    services.frigate = {
      hostname = "frigate.${hostname}";
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

    services.tailscale.serve = {
      enable = true;
      services."frigate".endpoints."tcp:80" = "http://127.0.0.1:${toString 5000}";
    };

    topology.self.services.frigate = {
      name = "Frigate NVR";
      details.listen.text = "http://frigate.${hostname}";
    };
  };
}
