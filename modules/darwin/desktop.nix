{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.packages = mkOption {
    type = types.listOf types.package;
    default = [];
  };

  config = rec {
    fonts.fontDir.enable = true;
    fonts.fonts = with pkgs; [
      ibm-plex
    ];
    environment.systemPackages = cfg.packages;
  };
}
