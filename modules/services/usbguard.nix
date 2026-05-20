{ lib, config, ... }:

{
  services.usbguard = lib.mkIf (!config.wsl.enable) {
    enable = lib.mkForce true;
    presentControllerPolicy = lib.mkDefault "allow";
    dbus.enable = lib.mkDefault true;
    IPCAllowedGroups = lib.mkDefault [
      "usbguard"
      "wheel"
    ];
  };
}
