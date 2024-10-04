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
      user = "dom";
      dataDir = "/home/dom/Documents";
      configDir = "/home/dom/Documents/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "device1" = { id = "DEVICE-ID-GOES-HERE"; };
          "device2" = { id = "DEVICE-ID-GOES-HERE"; };
        };
        folders = {
          "Documents" = {
            path = "/home/dom/Documents";
            devices = [ "device1" "device2" ];
          };
        };
        gui = {
          user = "dom";
          password = "password";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8384 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];
  };
}
