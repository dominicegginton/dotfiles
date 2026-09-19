{
  config,
  lib,
  tailnet,
  ...
}:

let
  cfg = config.services.silverbullet;
in

{
  config = lib.mkIf cfg.enable {
    # Ensure Tailscale is enabled, as Silverbullet relies on tsnsrv for secure access
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    # Core Silverbullet markdown notebook service settings
    services = {
      silverbullet = {
        listenAddress = lib.mkDefault "127.0.0.1";
        listenPort = lib.mkDefault 8765;
        openFirewall = lib.mkDefault false;
        user = lib.mkDefault "silverbullet";
        spaceDir = lib.mkDefault "/var/lib/silverbullet";
      };

      # Expose Silverbullet securely on the Tailnet using tsnsrv
      tsnsrv.services."silverbullet" = {
        toURL = "http://127.0.0.1:${toString config.services.silverbullet.listenPort}";
        tags = [ "tag:service-silverbullet" ];
      };

      # Declarative Restic snapshot backup job to Google Cloud Storage (GCS)
      restic.backups.silverbullet = {
        repository = "gs:silverbullet-backup-66ea520add6c51fb:/${config.networking.hostName}/silverbullet";
        passwordFile = config.sops.secrets."services/silverbullet/gcs-backup-key".path;
        initialize = true;
        paths = [ config.services.silverbullet.spaceDir ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
        timerConfig = {
          OnCalendar = "01:00:00";
          Persistent = true;
        };
      };
    };

    # Pass GCP Service Account credentials to Restic and set systemd ordering after Silverbullet service
    systemd.services.restic-backups-silverbullet = {
      environment.GOOGLE_APPLICATION_CREDENTIALS =
        config.sops.secrets."services/silverbullet/gcs-backup-key".path;
      after = [ "silverbullet.service" ];
      wants = [ "silverbullet.service" ];
    };

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-silverbullet = {
        network = tailnet;
        addresses = [ "https://silverbullet.${tailnet}" ];
      };

      services.silverbullet = {
        name = "Silverbullet";
        details.listen.text =
          config.services.silverbullet.listenAddress + ":" + toString config.services.silverbullet.listenPort;
      };
    };
  };
}
