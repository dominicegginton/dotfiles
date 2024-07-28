{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.plasma;
in

{
  options.modules.desktop.plasma.enable = mkEnableOption "sway";

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.printing.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
