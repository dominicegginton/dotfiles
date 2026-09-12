{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.huion;
in

{
  options.hardware.huion.enable = lib.mkEnableOption "Huion tablet support";

  config = lib.mkIf cfg.enable {
    # Enable Digimend kernel drivers for Huion graphics tablets
    services.xserver.digimend.enable = lib.mkDefault true;

    # Add huion-switcher utility to system packages
    environment.systemPackages = with pkgs; [
      huion-switcher
    ];
  };
}
