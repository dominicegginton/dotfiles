{ lib, ... }:

{
  services.usbguard = {
    enable = lib.mkForce true;
    presentControllerPolicy = lib.mkDefault "allow";
    dbus.enable = lib.mkDefault true;
    IPCAllowedGroups = lib.mkDefault [
      "usbguard"
      "wheel"
    ];
  };
}
