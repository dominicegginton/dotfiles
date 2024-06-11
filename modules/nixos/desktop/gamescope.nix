{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.modules.desktop.gamescope;
in
{
  options.modules.desktop.gamescope.enable = mkEnableOption "gamescope";

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.enable = false;
    services.printing.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;
    environment.systemPackages = with pkgs; [
      mangohud
      protonup
      lutris
      heroic
      bottles
    ];
  };
}
