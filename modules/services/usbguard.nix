{ ... }:

{
  services.usbguard = {
    enable = true;
    presentControllerPolicy = "allow";
    dbus.enable = true;
    IPCAllowedGroups = [
      "usbguard"
      "wheel"
    ];
  };
}
