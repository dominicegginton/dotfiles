{ config, lib, hostname, ... }:

{
  config = {
    services = {
      zabbixWeb.enable = config.services.zabbixServer.enable; 
      zabbixAgent = {
        enable = true;
        server = if config.services.zabbixServer.enable then "${hostname}" else "ghost-gs60"; 
        settings.Hostname = hostname;
      };
    };
  };
}
