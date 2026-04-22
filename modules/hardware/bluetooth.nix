{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth = {
      package = lib.mkForce pkgs.bluez;
      settings = {
        General = {
          MultiProfile = lib.mkDefault "multiple";
          FastConnectable = lib.mkDefault true;
          Enable = lib.mkDefault "Source,Sink,Media,Socket";
          Experimental = lib.mkDefault true;
        };
        LE = {
          ScanIntervalSuspend = lib.mkDefault 2240;
          ScanWindowSuspend = lib.mkDefault 224;
        };
      };
    };
  };
}
