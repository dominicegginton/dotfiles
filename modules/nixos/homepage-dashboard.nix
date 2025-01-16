{ config, lib, ... }:

let
  cfg = config.modules.services.homepage-dashboard;
  allowedRules = {
    allowedTCPPorts = [
      8087
    ];
    allowedUDPPorts = [ ];
  };
in

with lib;

{
  options.modules.services.homepage-dashboard.enable = mkEnableOption "homepage dashboard";

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = 8087;
      openFirewall = true;
      settings = {
        color = "stone";
        hideVersion = "true";
        useEqualHeights = true;
        statusStyle = "dot";
      };
      bookmarks = [
        {
          Developer = [
            { Github = [{ abbr = "GH"; href = "https://github.com/"; }]; }
          ];
        }
        {
          Burbage = [
            { "Home Assistant" = [{ abbr = "HA"; href = "http://ghost-gs60:8443/"; }]; }
            { Unifi = [{ abbr = "UTF"; href = "https://ghost-gs60:8443/"; }]; }
          ];
        }
        {
          Social = [
            { Reddit = [{ abbr = "RD"; href = "https://reddit.com/"; }]; }
            { Instagram = [{ abbr = "IG"; href = "https://instagram.com/"; }]; }
          ];
        }
        {
          Entertainment = [
            { YouTube = [{ abbr = "YT"; href = "https://youtube.com/"; }]; }
          ];
        }
      ];
      services = [

      ];
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
          search = {
            provider = "google";
            focus = true;
            showSearchSuggestions = true;
            target = "self";
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
            disk = [
              "/"
              "/mnt/data"
            ];
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = allowedRules.allowedTCPPorts;
    networking.firewall.allowedUDPPorts = allowedRules.allowedUDPPorts;
  };
}
