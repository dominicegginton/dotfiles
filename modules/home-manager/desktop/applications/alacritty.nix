{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.modules.desktop.applications.alacritty;
  jsonType = (pkgs.formats.json { }).type;
in

with lib;

{
  options.modules.desktop.applications.alacritty = {
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
