{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.bluetooth;
in {
  options.modules.bluetooth.enable = mkEnableOption "bluetooth";

  config = mkIf cfg.enable rec {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;
    services.blueman.enable = true;
  };
}
