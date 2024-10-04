{ config, lib, ... }:

let
  cfg = config.modules.services.syncthing;
in

with lib;

{
  options.modules.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = mkIf cfg.enable {
    sops.secrets."syncthing.password".neededForUsers = true;

    services.syncthing = {
      enable = true;
      user = "dom";
      dataDir = "/home/dom/Documents";
      configDir = "/home/dom/Documents/.config/syncthing";
      overrideFolders = true;
      settings = {
        folders = {
          "Documents" = {
            path = "/home/dom/Documents";
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8384 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];
  };
}
