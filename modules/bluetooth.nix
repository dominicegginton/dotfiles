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

  config = mkIf cfg.enable {
    hardware = {
      bluetooth = {
        enable = true;
        package = pkgs.bluez;
      };
    };

    services.blueman.enable = true;
  };
}
