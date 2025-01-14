{ config, lib, ... }:

let
  cfg = config.modules.services.homepage-dashboard;
in

with lib;

{
  options.modules.services.homepage-dashboard.enable = mkEnableOption "Homepage Dashboard";

  config = mkIf cfg.enable {
    services.homepage-dashboard.enable = true;
  };
}
