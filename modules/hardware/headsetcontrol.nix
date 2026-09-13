{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.headsetcontrol;
in

{
  options.hardware.headsetcontrol = {
    enable = lib.mkEnableOption "Enable HeadsetControl support for Bluetooth headsets.";

    gnomeExtension = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the GNOME Shell extension for HeadsetControl when GNOME is active.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install headsetcontrol CLI utility
    environment.systemPackages = with pkgs; [
      headsetcontrol
    ];

    # Add headsetcontrol udev rules so non-root users can access headset HID devices
    services.udev.packages = with pkgs; [
      headsetcontrol
    ];

    # Enable GNOME Shell extension for HeadsetControl when GNOME is active
    display.gnome.extensions = lib.mkIf (config.display.gnome.enable && cfg.gnomeExtension) [
      pkgs.gnomeExtensions.headsetcontrol
    ];
  };
}
