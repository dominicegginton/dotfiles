{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.services.unifi;
in

with lib;

{
  options.modules.services.unifi.enable = mkEnableOption "unifi";

  config = mkIf cfg.enable {
    services.unifi.enable = true;
  };
}
