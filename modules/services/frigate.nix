{
  config,
  lib,
  tailnet,
  ...
}:

let
  cfg = config.services.frigate;
in

{
  config = lib.mkIf cfg.enable {
    # Ensure Tailscale is enabled, as Frigate relies on tsnsrv for secure Tailnet exposure
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    # Primary Frigate NVR configuration
    services.frigate = {
      hostname = "frigate.${tailnet}";
      settings = {
        auth.enabled = false; # Authentication is handled upstream at the Tailnet / tsnsrv layer
        motion.enabled = true;
        record.enabled = true;
        snapshots.enabled = true;
        detect = {
          enabled = true;
          fps = 5;
        };
      };
    };

    # Expose Frigate securely on the Tailnet using tsnsrv without opening public firewall ports
    services.tsnsrv.services."frigate" = {
      toURL = "http://127.0.0.1:${toString 5000}";
      tags = [ "tag:service-frigate" ];
    };

    # Declarative Restic snapshot backup job to Google Cloud Storage (GCS)
    services.restic.backups.frigate = {
      repository = "gs:frigate-backup-66ea520add6c51fb:/${config.networking.hostName}/frigate";
      passwordFile = config.sops.secrets."services/frigate/gcs-backup-key".path;
      initialize = true;
      paths = [ "/var/lib/frigate" ]; # Storage location for Frigate database, snapshots, and recordings
      exclude = [
        "recordings/*" # Exclude heavy video recordings from cloud snapshot backups
        ".cache/*"
        ".keras/*"
        "*.db-shm"
        "*.db-wal"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
      timerConfig = {
        OnCalendar = "04:00:00";
        Persistent = true;
      };
    };

    # Pass GCP Service Account credentials to Restic and set systemd ordering after Frigate
    systemd.services.restic-backups-frigate = {
      environment.GOOGLE_APPLICATION_CREDENTIALS =
        config.sops.secrets."services/frigate/gcs-backup-key".path;
      after = [ "frigate.service" ];
      wants = [ "frigate.service" ];
    };

    # Impermanence configuration: persist Frigate data directory across ephemeral root reboots
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/frigate"
    ];

    # Network topology visualizer metadata
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
