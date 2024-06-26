{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.modules.desktop.applications.zed-editor;
in

with lib;

{

  options.modules.desktop.applications.zed-editor.enable = mkEnableOption "zed-editor";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ unstable.zed-editor ];
  };
}
