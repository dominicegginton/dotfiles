{ lib, config, ... }:

{
  services.usbguard = let notWSL = !config.wsl.enable; in lib.mkIf notWSL {
    enable = lib.mkForce true;
    presentControllerPolicy = lib.mkDefault "allow";
    dbus.enable = lib.mkDefault true;
    IPCAllowedGroups = lib.mkDefault [
      "usbguard"
      "wheel"
    ];
  };
}
