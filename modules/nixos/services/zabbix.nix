{ ... }:

{
  config = {
    services = {
      # zabbixWeb = lib.mkIf config.services.zabbixServer.enable {
      #   enable = true;
      #   frontend = "nginx";
      #   hostname = "zabbix.${hostname}";
      # }; 
      # zabbixAgent = {
      #   enable = true;
      #   server = if config.services.zabbixServer.enable then "${hostname}" else "ghost-gs60"; 
      #   settings.Hostname = hostname;
      # };
    };
  };
}
