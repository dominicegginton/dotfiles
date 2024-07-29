{ config, lib, pkgs, ... }:

let
  cfg = config.modules.desktop.plasma;
in

with lib;

{
  options.modules.desktop.plasma.enable = mkEnableOption "Plasma desktop environment";

  config = mkIf cfg.enable {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = "1";
    };

    programs.plasma = {
      enable = true;
      workspace = { };
      panels = [ ];
      window-rules = [ ];
      powerdevil = { };
      shortcuts = { };
      configFile = { };
    };
  };
}
