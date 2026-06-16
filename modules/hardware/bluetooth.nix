{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkMerge [
    {
      # Enable Bluetooth by default on all systems except WSL
      hardware.bluetooth.enable = lib.mkDefault (!config.wsl.enable);

      # Enable blueman for non-GNOME systems to provide a GUI manager
      services.blueman.enable = lib.mkDefault (
        config.hardware.bluetooth.enable && !config.display.gnome.enable
      );
    }
    (lib.mkIf config.hardware.bluetooth.enable {
      # Enable uinput and uhid modules to allow BlueZ to create input devices in userspace
      boot.kernelModules = [
        "uinput"
        "uhid"
      ];

      hardware.bluetooth = {
        # Use the BlueZ Bluetooth stack
        package = lib.mkDefault pkgs.bluez;

        # Automatically power on the Bluetooth controller at boot
        powerOnBoot = lib.mkDefault true;

        # Configure Bluetooth settings for improved performance and compatibility
        settings = {
          General = {
            MultiProfile = lib.mkDefault "multiple"; # Allow multiple Bluetooth profiles simultaneously
            FastConnectable = lib.mkDefault true; # Quicker pairing and reconnection
            Enable = lib.mkDefault "Source,Sink,Media,Socket,Input,Hogp"; # Enable audio, media control, input, and BLE HID profiles
            Experimental = lib.mkDefault true; # Enable experimental BlueZ features
          };

          # Configure Input settings for Bluetooth keyboards and mice
          Input = {
            UserspaceHID = lib.mkDefault true; # Enable userspace HID for better compatibility with some devices
          };

          # Configure Bluetooth Low Energy (BLE) settings
          LE = {
            ScanIntervalSuspend = lib.mkDefault 2240;
            ScanWindowSuspend = lib.mkDefault 224;
          };
        };
      };
    })
  ];
}
