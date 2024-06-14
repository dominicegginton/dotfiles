{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.desktop;
in

with lib;

{
  options.modules.desktop.packages = mkOption {
    type = types.listOf types.package;
    default = [ ];
  };

  config = {
    fonts.fontDir.enable = true;
    fonts.fonts = with pkgs; [
      ibm-plex
    ];
    environment.systemPackages = cfg.packages;
  };
}
