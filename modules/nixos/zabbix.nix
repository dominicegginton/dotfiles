{ config, lib, hostname, ... }:

{
  config = {
    services = {
      zabbixWeb = mkIf config.services.zabbixServer.enable {
        enable = true;
        forntend = "nginx";
        hostname = "zabbix.${hostname}";
      }; 
      zabbixAgent = {
        enable = true;
        server = if config.services.zabbixServer.enable then "${hostname}" else "ghost-gs60"; 
        settings.Hostname = hostname;
      };
    };
  };
}
