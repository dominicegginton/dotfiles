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
    services.tsnsrv.services."frigate" = {
      toURL = "http://127.0.0.1:${toString 5000}";
    };

    services.gcs-backup.frigate = {
      enable = true;
      bucket = "gs://frigate-backup-66ea520add6c51fb";
      directories = [ "/var/lib/frigate" ]; # Default storage for Frigate recordings
      interval = "04:00:00";
      delete = true;
      extraArgs = [ "--exclude=^(recordings|\\.cache|\.keras)/.*|.*\\.db-(shm|wal)$" ];
      serviceAccountKeyFile = config.sops.secrets."services/frigate/gcs-backup-key".path;
      wantedBy = [ "frigate.service" ];
      wants = [ "frigate.service" ];
    };

    topology.self = {
      interfaces.tsnsrv-frigate = {
        network = tailnet;
        addresses = [ "https://frigate.${tailnet}" ];
      };

      services.frigate = {
        name = "Frigate";
        details.listen.text = config.services.frigate.hostname + ":5000";
      };
    };
  };
}
