{ config, lib, pkgs, hostname, tailnet, ... }:

with lib;

let
  cfg = config.modules.services.homepage-dashboard;
  settingsFormat = pkgs.formats.yaml { };
in

{
  options.modules.services.homepage-dashboard = {
    enable = mkEnableOption "homepage dashboard";
    listenPort = mkOption {
      type = types.int;
      default = 8087;
      description = "Port to listen on";
    };
    bookmarks = mkOption {
      inherit (settingsFormat) type;
      default = [ ];
      description = "Bookmarks";
    };
    monitorDisks = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Disks to monitor";
    };
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = cfg.listenPort;
      settings = {
        color = "stone";
        hideVersion = "true";
        useEqualHeights = true;
        statusStyle = "dot";
      };
      bookmarks = cfg.bookmarks;
      widgets = [
        {
          datetime = {
            format = {
              dateStyle = "long";
              timeStyle = "long";
            };
          };
        }
        {
          resources = {
            cpu = true;
            cputemp = true;
            memory = true;
            units = "metric";
            tempmin = 0;
            tempmax = 100;
            refresh = 50000;
            expanded = true;
            disk = cfg.monitorDisks;
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      tailscaleAuth.enable = true;
      tailscaleAuth.virtualHosts = [ "dash.${hostname}" ];
      virtualHosts."dash.${hostname}" = {
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.listenPort}";
      };
    };
    topology.self.services.homepage-dashboard = {
      name = "Homepage Dashboard";
      details = {
        listen = {
          text = "dash.${hostname}";
        };
      };
    };
  };
}
