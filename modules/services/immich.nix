{
  config,
  lib,
  tailnet,
  ...
}:

let
  cfg = config.services.immich;
in

{
  config = lib.mkIf cfg.enable {
    # Core Immich photo and video management server configuration
    services.immich = {
      host = lib.mkDefault "127.0.0.1";
      port = lib.mkDefault 2283;
      settings = {
        server.externalDomain = lib.mkDefault "https://immich.${tailnet}";
        passwordLogin.enabled = lib.mkDefault false; # Password login disabled in favor of OIDC/SSO
        oauth = {
          enabled = lib.mkDefault true;
          issuerUrl = lib.mkDefault "https://idp.${tailnet}"; # Headscale/tsidp OAuth provider
          clientId = lib.mkDefault "d256edd52e37846b4aae2e485c1d823e";
          clientSecret._secret = config.sops.secrets."services/immich/oauth-secret".path; # Decrypted OAuth secret via sops-nix
          autoRegister = lib.mkDefault true;
          autoLaunch = lib.mkDefault true;
        };
      };
    };

    # Expose Immich securely over Tailscale with Funnel support enabled
    services.tsnsrv.services."immich" = {
      toURL = "http://127.0.0.1:${toString config.services.immich.port}";
      funnel = lib.mkDefault true;
      tags = [ "tag:service-immich" ];
    };

    # Declarative Restic snapshot backup job to Google Cloud Storage (GCS)
    services.restic.backups.immich = {
      repository = "gs:immich-backup-66ea520add6c51fb:/${config.networking.hostName}/immich";
      passwordFile = config.sops.secrets."services/immich/gcs-backup-key".path;
      initialize = true;
      paths = [ config.services.immich.mediaLocation ];
      exclude = [
        "thumbs/*" # Exclude regenerated thumbnails to save bandwidth and GCS storage
        "encoded-video/*" # Exclude transcoded video caches
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
      timerConfig = {
        OnCalendar = "02:00:00";
        Persistent = true;
      };
    };

    # Pass GCP Service Account credentials to Restic and set systemd ordering after Immich server
    systemd.services.restic-backups-immich = {
      environment.GOOGLE_APPLICATION_CREDENTIALS =
        config.sops.secrets."services/immich/gcs-backup-key".path;
      after = [ "immich-server.service" ];
      wants = [ "immich-server.service" ];
    };

    # Impermanence configuration: persist Immich media and PostgreSQL data across ephemeral root reboots
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      config.services.immich.mediaLocation
      "/var/lib/postgresql"
    ];

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-immich = {
        network = tailnet;
        addresses = [ "https://immich.${tailnet}" ];
      };

      services.immich = {
        name = "Immich";
        details.listen.text = config.services.immich.host + ":" + toString config.services.immich.port;
      };
    };
  };
}
