{ config
, lib
, pkgs
, username
, ...
}:

let
  cfg = config.modules.services.steam;
in

with lib;

{
  options.modules.services.steam.enable = mkEnableOption "deluge";

  config = mkIf cfg.enable {

    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;


    environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATH =
      "\${HOME}/.steam/root/compatibilitytools.d";

    environment.systemPackages = with pkgs; [
      steam-run
      mangohud
      protonup
    ];
  };
}
