{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.gamescope;
in {
  options.modules.desktop.gamescope.enable = mkEnableOption "gamescope";

  config = mkIf cfg.enable rec {
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];
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
