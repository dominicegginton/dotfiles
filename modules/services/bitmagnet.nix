{
  lib,
  config,
  hostname,
  ...
}:

let
  virtualHost = "bitmagnet.${hostname}";
in

{
  config = lib.mkIf config.services.bitmagnet.enable {
    services.nginx = {
      enable = true;
      tailscaleAuth = {
        enable = true;
        virtualHosts = [ virtualHost ];
      };
      virtualHosts."${virtualHost}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass =
          "http://localhost:${toString config.services.bitmagnet.settings.http_server.port}";
      };
    };

    topology.self.services.bitmagnet = {
      name = "BitMagnet";
      details.listen.text = virtualHost;
    };
  };
}
