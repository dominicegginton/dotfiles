{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.samba;
in {
  options.modules.services.samba.enable = mkEnableOption "samba";

  config = mkIf cfg.enable rec {
    services.samba.enable = true;
  };
}
