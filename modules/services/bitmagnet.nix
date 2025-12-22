{ lib, config, hostname, ... }:

{
  config = lib.mkIf config.services.bitmagnet.enable {
    services.nginx = {
      enable = true;
      virtualHosts."bitmagnet.${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString config.services.bitmagnet.settings.http_server.port}";
      };
    };
  };
}
