{
  config,
  lib,
  hostname,
  tailnet,
  ...
}:

let
  cfg = config.services.beszel;
in

{
  options.services.beszel.enable = lib.mkEnableOption "Beszel monitoring";

  config = lib.mkIf (cfg.enable && !config.wsl.enable) {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true for Beszel";
      }
    ];

    services.beszel.hub = {
      port = lib.mkDefault 8090;
      host = lib.mkDefault "127.0.0.1";
      environment = {
        BESZEL_PASSWORD_AUTH = "false";
        BESZEL_OIDC_ISSUER_URL = "https://idp.${tailnet}";
        BESZEL_OIDC_CLIENT_ID = "381ecd662308d2ee03c219583d4fc359";
        BESZEL_OIDC_REDIRECT_URL = "https://beszel.${tailnet}/api/oauth2-redirect";
        BESZEL_OIDC_AUTO_REGISTER = "true";
        BESZEL_OIDC_AUTO_LAUNCH = "true";
      };
      environmentFile = config.sops.secrets."services/beszel/hub".path;
    };

    services.tsnsrv.services."beszel" = lib.mkIf config.services.beszel.hub.enable {
      toURL = "http://127.0.0.1:${toString config.services.beszel.hub.port}";
    };

    services.beszel.agent = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
      environmentFile = lib.mkDefault config.sops.secrets."services/beszel/agent".path;
    };

    topology.self = lib.mkIf config.services.beszel.hub.enable {
      interfaces.tsnsrv-beszel = {
        network = tailnet;
        addresses = [ "https://beszel.${tailnet}" ];
      };

      services.beszel-hub = {
        name = "Beszel Hub";
        details.listen.text = "127.0.0.1:${toString config.services.beszel.hub.port}";
      };
    };
  };
}
