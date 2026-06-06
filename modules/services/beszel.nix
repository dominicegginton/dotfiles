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
    };

    services.tsnsrv.services."beszel" = lib.mkIf config.services.beszel.hub.enable {
      toURL = "http://127.0.0.1:${toString config.services.beszel.hub.port}";
    };

    services.beszel.agent = {
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
