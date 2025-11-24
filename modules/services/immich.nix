{ config, lib, hostname, ... }:

{
  config = lib.mkIf config.services.immich.enable {
    services.immich.host = "0.0.0.0";
    services.nginx = {
      enable = true;
      virtualHosts."immich.${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString 2283}";
      };
    };
  };
}

