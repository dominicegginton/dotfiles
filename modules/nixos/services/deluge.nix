{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.deluge;
in {
  options.modules.services.deluge.enable = mkEnableOption "deluge";

  config = mkIf cfg.enable {
    services.deluge.enable = true;
    services.deluge.web.enable = true;
  };
}
