{ config, lib, pkgs, ... }:

let
  cfg = config.modules.display.plasma;
in

with lib;

{
  options.modules.display.plasma.enable = mkEnableOption "Plasma desktop environment";

  config = mkIf cfg.enable {
    programs.plasma.enable = true;
  };
}
