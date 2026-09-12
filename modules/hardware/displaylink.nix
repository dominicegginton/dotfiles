{
  config,
  lib,
  ...
}:

let
  cfg = config.hardware.displaylink;
in

{
  options.hardware.displaylink = {
    enable = lib.mkEnableOption "DisplayLink USB graphics support";
  };

  config = lib.mkIf cfg.enable {
    # Enable DisplayLink video driver in NixOS
    services.xserver.videoDrivers = lib.mkDefault [ "displaylink" ];

    # EVDI (Extensible Virtual Display Interface) kernel module for Wayland compatibility
    boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
    boot.kernelModules = [ "evdi" ];
    boot.initrd.kernelModules = [ "evdi" ];
  };
}
