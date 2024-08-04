{ pkgs, config, lib, ... }:

let
  cfg = config.modules.display.applications.firefox;
in

with lib;

{
  options.modules.display.applications.firefox = {
    enable = mkEnableOption "Firefox Developer Edition";
    package = mkOption {
      type = types.package;
      default = pkgs.firefox-bin;
      description = "The package to use for Firefox Developer Edition";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = cfg.package;
    };
  };
}
