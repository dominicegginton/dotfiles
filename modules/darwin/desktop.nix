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
    environment.systemPackages = cfg.packages;
  };
}
