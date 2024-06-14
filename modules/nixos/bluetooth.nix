{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.bluetooth;
in

with lib;

{
  options.modules.bluetooth.enable = mkEnableOption "bluetooth";

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;
    services.blueman.enable = true;
  };
}
