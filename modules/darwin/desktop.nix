{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {};

  config = {
    environment.systemPackages = with pkgs; [] ++ cfg.packages;

    fonts = {
      fontDir.enable = true;
      fonts = with pkgs; [
        ibm-plex
      ];
    };
  };
}
