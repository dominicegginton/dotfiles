{ lib, config, ... }:
let
  notWSL = !config.wsl.enable;
in
{
  services.usbguard = lib.mkIf notWSL {
    enable = lib.mkForce true;
    presentControllerPolicy = lib.mkDefault "allow";
    dbus.enable = lib.mkDefault true;
    IPCAllowedGroups = lib.mkDefault [
      "usbguard"
      "wheel"
    ];
    # Allow Bluetooth devices (Class e0:01:01)
    rules = ''
      allow with-interface equals { e0:01:01 }
    '';
  };
}
