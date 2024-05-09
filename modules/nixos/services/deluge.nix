{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.deluge;
  nixosCfg = config.modules.nixos;
in {
  options.modules.services.deluge.enable = mkEnableOption "deluge";

  config = mkIf (cfg.enable && nixosCfg.role == "server") rec {
    services.deluge.enable = true;
    services.deluge.web.enable = true;
  };
}
