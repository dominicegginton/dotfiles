{
  config,
  lib,
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
        oauth = {
          enabled = lib.mkDefault true;
          issuerUrl = lib.mkDefault "https://idp.${tailnet}";
          clientId = lib.mkDefault "immich";
          clientSecret._secret = config.sops.secrets."services/immich/oauth-secret".path;
          autoRegister = lib.mkDefault true;
        };
      };
    };

    services.tailscale.serve = {
      enable = true;
      services."immich".endpoints."tcp:80" = "http://127.0.0.1:${toString config.services.immich.port}";
    };

    topology.self.services.immich = {
      name = "Immich";
      details.listen.text = "https://immich.${tailnet}";
    };
  };
}
