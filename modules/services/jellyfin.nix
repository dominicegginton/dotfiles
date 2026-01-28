{
  config,
  lib,
  hostname,
  ...
}:

{
  config = lib.mkIf config.services.jellyfin.enable {
    services.nginx = {
      enable = true;
      virtualHosts."jf.${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString 8096}";
      };
    };
  };
}
