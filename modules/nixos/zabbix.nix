{ config, lib, hostname, ... }:

{
  config = lib.mkIf config.services.zabbixServer.enable {
    services = {
      zabbixWeb.enable = true;
      zabbixAgent = {
        enable = true;
        server = "localhost";
        settings."Hostname" = hostname;
      };
    };
  };
}
