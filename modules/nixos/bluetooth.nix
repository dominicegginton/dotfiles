{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth.package = pkgs.bluez;
    services.blueman.enable = true;
  };
}
