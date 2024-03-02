{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.sops;
in {
  options.modules.sops = {
    enable = mkEnableOption "sops";
  };

  config = mkIf cfg.enable {
    sops.defaultSopsFile = mkIf cfg.enable ../secrets.yaml;
  };
}
