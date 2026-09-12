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
    services.silverbullet = {
      listenAddress = lib.mkDefault "127.0.0.1";
      listenPort = lib.mkDefault 8765;
      openFirewall = lib.mkDefault false;
      user = lib.mkDefault "silverbullet";
      spaceDir = lib.mkDefault "/var/lib/silverbullet";
    };

    # Systemd process sandboxing to harden the Silverbullet daemon
    systemd.services.silverbullet.serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      PrivateMounts = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ProtectProc = "invisible";
      ProcSubset = "pid";
      UMask = "0077";
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
      CapabilityBoundingSet = "";
      KeyringMode = "private";
      ReadWritePaths = [
        config.services.silverbullet.spaceDir
      ];
    };

    # Impermanence configuration: persist Silverbullet space data across ephemeral root reboots
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      config.services.silverbullet.spaceDir
    ];

    # Expose Silverbullet securely on the Tailnet using tsnsrv
    services.tsnsrv.services."silverbullet" = {
      toURL = "http://127.0.0.1:${toString config.services.silverbullet.listenPort}";
      tags = [ "tag:service-silverbullet" ];
    };

    # Declarative Restic snapshot backup job to Google Cloud Storage (GCS)
    services.restic.backups.silverbullet = {
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
