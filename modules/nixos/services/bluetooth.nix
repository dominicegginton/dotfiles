{ config, pkgs, lib, ... }:

let
  cfg = config.modules.services.bluetooth;
in

with lib;

{
  options.modules.services.bluetooth.enable = mkEnableOption "bluetooth";

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;
    services.blueman.enable = true;
  };
}
