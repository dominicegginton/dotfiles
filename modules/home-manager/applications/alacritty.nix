{ pkgs, config, lib, ... }:

let
  cfg = config.modules.display.applications.alacritty;

  jsonType = (pkgs.formats.json { }).type;
in

with lib;

{
  options.modules.display.applications.alacritty = {
    enable = mkEnableOption "Alacritty terminal emulator";
    settings = mkOption {
      type = jsonType;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = cfg.settings;
    };
  };
}
