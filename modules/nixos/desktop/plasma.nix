{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.plasma;
in {
  options.modules.desktop.plasma.enable = mkEnableOption "plasma";

  config = mkIf cfg.enable rec {
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    hardware.pulseaudio.enable = false;
    services.printing.enable = true;
    services.pipewire = rec {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
