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
      listenAddress = lib.mkDefault "0.0.0.0";
      listenPort = lib.mkDefault 8765;
      openFirewall = lib.mkDefault true;
      user = lib.mkDefault "silverbullet";
      spaceDir = lib.mkDefault "/var/lib/silverbullet";
    };

    # Persistent storage for Silverbullet data
    environment.persistence."/persist".directories = [
      config.services.silverbullet.spaceDir
    ];

    services.tsnsrv.services."silverbullet" = {
      toURL = "http://127.0.0.1:${toString config.services.silverbullet.listenPort}";
    };

    services.gcs-backup.silverbullet = {
      enable = true;
      bucket = "gs://silverbullet-backup-66ea520add6c51fb";
      directories = [ config.services.silverbullet.spaceDir ];
      interval = "daily";
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
