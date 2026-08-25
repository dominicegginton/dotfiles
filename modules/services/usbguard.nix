{
  lib,
  config,
  pkgs,
  ...
}:

let
  notWSL = !config.wsl.enable;
in

{
  config = lib.mkIf notWSL {
    services.usbguard = {
      enable = lib.mkDefault true;
      presentControllerPolicy = lib.mkDefault "allow";
      dbus.enable = lib.mkDefault true;
      IPCAllowedGroups = lib.mkDefault [
        "usbguard"
        "wheel"
      ];
      # Allow Bluetooth and internal (hardwired) devices, as well as root/external hubs
      rules = lib.mkDefault ''
        allow with-interface e0:01:01
        allow with-connect-type "hardwired"
        allow id 1d6b:*
        allow with-interface 09:00:00
        allow id 1050:*
      '';
    };
  };
}
