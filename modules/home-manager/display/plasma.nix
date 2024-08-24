{ config, lib, ... }:

let
  cfg = config.modules.display.plasma;
in

with lib;

{
  options.modules.display.plasma.enable = mkEnableOption "Plasma desktop environment";
  options.modules.display.plasma.shortcuts = mkOption { type = types.attrs; };
  options.modules.display.plasma.configFile = mkOption { type = types.attrs; };

  config = mkIf cfg.enable {
    programs.plasma.enable = true;
    programs.plasma.shortcuts = cfg.shortcuts;
    programs.plasma.configFile = cfg.configFile;
  };
}
