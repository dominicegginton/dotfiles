{
  config,
  lib,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.frigate.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services.frigate = {
      hostname = "frigate.${tailnet}";
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

    # Tailscale Service Configuration for Frigate
    services.tailscale.serve = {
      enable = true;
      services."frigate".endpoints."tcp:80" = "http://127.0.0.1:${toString 5000}";
    };

    services.gcs-backup.frigate = {
      enable = true;
      bucket = "gs://frigate-backup";
      directories = [ "/var/lib/frigate" ]; # Default storage for Frigate recordings
      interval = "daily";
      serviceAccountKeyFile = config.sops.secrets."services/frigate/gcs-backup-key".path;
    };

    topology.self.services.frigate = {
      name = "Frigate NVR";
      details.listen.text = "http://frigate.${tailnet}";
    };
  };
}
