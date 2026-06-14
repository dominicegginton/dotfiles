{ lib, config, ... }:

let
  cfg = config.services.usbguard;
  notWSL = !config.wsl.enable;
in

{
  options.services.usbguard.extraRules = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = ''
      Extra rules to append to the default USBGuard policy.

      To discover USB devices to whitelist:
      1. Run `run0 usbguard list-devices`
      2. Identify the device and its attributes (ID, serial, hash, etc.)
      3. Add a rule to this option, e.g., `allow id 1234:abcd`
    '';
  };

  config.services.usbguard = lib.mkIf notWSL {
    enable = lib.mkDefault true;
    presentControllerPolicy = lib.mkDefault "allow";
    dbus.enable = lib.mkDefault true;
    IPCAllowedGroups = lib.mkDefault [
      "usbguard"
      "wheel"
    ];
    # Allow Bluetooth and internal (hardwired) devices
    rules = lib.mkDefault (
      ''
        allow with-interface e0:01:01
        allow with-connect-type "hardwired"
      ''
      + cfg.extraRules
    );
  };
}
