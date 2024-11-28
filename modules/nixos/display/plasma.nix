{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.display.plasma;
in

{
  options.modules.display.plasma.enable = mkEnableOption "plasma";

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.printing.enable = true;
    environment.systemPackages = with pkgs.kdePackages; [ kgpg dolphin-plugins ];
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
