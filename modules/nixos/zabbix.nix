{ hostname, ... }:

{
  config = {
    services = {
      zabbixAgent = {
        enable = true;
        server = "localhost";
        settings."Hostname" = hostname;
      };

      zabbixServer.enable = true;
      zabbixWeb.enable = true;
    };
  };
}
