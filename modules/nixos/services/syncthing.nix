{ config, lib, ... }:

let
  cfg = config.modules.services.syncthing;
in

with lib;

{
  options.modules.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = mkIf cfg.enable {
    sops.secrets."syncthing.latitude-7390.id".neededForUsers = true;
    sops.secrets."syncthing.ghost-gs60.id".neededForUsers = true;

    services.syncthing = {
      enable = true;
      user = "dom";
      dataDir = "/home/dom/Documents";
      configDir = "/home/dom/Documents/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "device1" = { id = config.sops.secrets."syncthing.latitude-7390.id".path; };
          "device2" = { id = config.sops.secrets."syncthing.ghost-gs60.id".path; };
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
