{
  config,
  lib,
  hostname,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.immich.enable {
    services.immich = {
      host = lib.mkDefault "0.0.0.0";
      port = lib.mkDefault 2283;
      settings = {
        server.externalDomain = lib.mkDefault "https://immich.${tailnet}";
        passwordLogin.enabled = lib.mkDefault false;
        oauth = {
          enabled = lib.mkDefault true;
          issuerUrl = lib.mkDefault "https://idp.${tailnet}";
          clientId = lib.mkDefault "d256edd52e37846b4aae2e485c1d823e";
          clientSecret._secret = config.sops.secrets."services/immich/oauth-secret".path;
          autoRegister = lib.mkDefault true;
          autoLaunch = lib.mkDefault true;
        };
      };
    };

    services.tsnsrv.services."immich" = {
      toURL = "http://127.0.0.1:${toString config.services.immich.port}";
      funnel = lib.mkDefault true;
    };

    services.gcs-backup.immich = {
      enable = true;
      bucket = "gs://immich-backup-66ea520add6c51fb";
      directories = [ config.services.immich.mediaLocation ];
      interval = "02:00:00";
      delete = true;
      extraArgs = [ "--exclude=^(thumbs|encoded-video)/.*" ];
      serviceAccountKeyFile = config.sops.secrets."services/immich/gcs-backup-key".path;
      wantedBy = [ "immich-server.service" ];
      wants = [ "immich-server.service" ];
    };

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
