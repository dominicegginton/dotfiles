{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth = {
      # Use the BlueZ Bluetooth stack
      package = lib.mkForce pkgs.bluez;

      # Configure Bluetooth settings for improved performance and compatibility
      settings = {
        General = {
          MultiProfile = lib.mkDefault "multiple"; # Allow multiple Bluetooth profiles simultaneously
          FastConnectable = lib.mkDefault true; # Quicker pairing and reconnection
          Enable = lib.mkDefault "Source,Sink,Media,Socket"; # Enable audio and media control profiles
          Experimental = lib.mkDefault true; # Enable experimental BlueZ features
        };

        # Configure Bluetooth Low Energy (BLE) settings
        LE = {
          ScanIntervalSuspend = lib.mkDefault 2240;
          ScanWindowSuspend = lib.mkDefault 224;
        };
      };
    };
  };
}
