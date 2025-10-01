{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth = {
      package = pkgs.bluez;
      settings = {
        General = {
          MultiProfile = "multiple";
          FastConnectable = true;
        };
        LE = {
          ScanIntervalSuspend = 2240;
          ScanWindowSuspend = 224;
        };
      };
    };
    services.blueman.enable = true;
  };
}
