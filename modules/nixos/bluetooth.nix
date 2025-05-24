{ config, pkgs, lib, ... }:

{
  options.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf config.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };
    services.blueman.enable = true;
  };
}
