{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.plex;
in {
  options.modules.services.plex.enable = mkEnableOption "plex media server";

  config = mkIf cfg.enable rec {
    services.plex.enable = true;
  };
}