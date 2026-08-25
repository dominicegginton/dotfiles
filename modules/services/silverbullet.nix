{
  config,
  lib,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.silverbullet.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services.silverbullet = {
      listenAddress = lib.mkDefault "127.0.0.1";
      listenPort = lib.mkDefault 8765;
      openFirewall = lib.mkDefault false;
      user = lib.mkDefault "silverbullet";
      spaceDir = lib.mkDefault "/var/lib/silverbullet";
    };

    systemd.services.silverbullet.serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
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
      ReadWritePaths = [
        config.services.silverbullet.spaceDir
      ];
    };

    # Persistent storage for Silverbullet data
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      config.services.silverbullet.spaceDir
    ];

    services.tsnsrv.services."silverbullet" = {
      toURL = "http://127.0.0.1:${toString config.services.silverbullet.listenPort}";
      tags = [ "tag:service-silverbullet" ];
    };

    services.gcs-backup.silverbullet = {
      enable = true;
      bucket = "gs://silverbullet-backup-66ea520add6c51fb";
      directories = [ config.services.silverbullet.spaceDir ];
      interval = "01:00:00";
      delete = true;
      serviceAccountKeyFile = config.sops.secrets."services/silverbullet/gcs-backup-key".path;
      wantedBy = [ "silverbullet.service" ];
      wants = [ "silverbullet.service" ];
    };

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
