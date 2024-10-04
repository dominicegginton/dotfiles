{ config, lib, ... }:

let
  cfg = config.modules.services.syncthing;
in

with lib;

{
  options.modules.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      settings = {
        folders = {
          "Documents" = {
            id = "documents";
            path = "/home/dom/Documents";
            rescanIntervalS = 60;
            ignorePerms = false;
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];
  };
}
