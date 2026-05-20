{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth = {
      # Use the BlueZ Bluetooth stack.
      package = lib.mkForce pkgs.bluez;

      # Configure Bluetooth settings for improved performance and compatibility.
      settings = {
        General = {
          MultiProfile = lib.mkDefault "multiple"; # Allow multiple Bluetooth profiles to be active simultaneously for better device compatibility.
          FastConnectable = lib.mkDefault true; # Fast connection mode for quicker pairing and reconnection with known devices.
          Enable = lib.mkDefault "Source,Sink,Media,Socket"; # Enable support for various Bluetooth profiles including audio source, sink, media control, and socket for better device compatibility.
          Experimental = lib.mkDefault true; # Enable experimental features in BlueZ for improved performance and support for newer Bluetooth standards and devices.
        };

        # Configure Bluetooth Low Energy (BLE) settings for improved performance and battery life when using BLE devices.
        LE = {
          ScanIntervalSuspend = lib.mkDefault 2240;
          ScanWindowSuspend = lib.mkDefault 224;
        };
      };
    };
  };
}
