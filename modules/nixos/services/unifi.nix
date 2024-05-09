{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.unifi;
in {
  options.modules.services.unifi.enable = mkEnableOption "unifi";

  config = mkIf cfg.enable rec {
    services.unifi.enable = true;
  };
}
