{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.homebrew;
in {
  options.modules.homebrew = {
    enable = mkEnableOption "Homebrew";

    autoUpdate = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically update Homebrew and its packages";
    };

    taps = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew taps to add";
    };

    brews = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew packages to install";
    };

    casks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew casks to install";
    };

    masApps = mkOption {
      type = types.attrs;
      default = {};
      description = "macOS App Store apps to install";
    };
  };

  congig = mkIf cfg.enable {
    homebrew.enable = true;
    homebrew.onActivation.autoUpdate = mkIf cfg.autoUpdate true;
    homebrew.onActivation.cleanup = "zap";
    homebrew.global.brewfile = true;
    homebrew.global.lockfiles = false;
    homebrew.taps = ["homebrew/cask-versions"] ++ cfg.taps;
    homebrew.brews = [] ++ cfg.brews;
    homebrew.casks = [] ++ cfg.casks;
    homebrew.masApps = {} ++ cfg.masApps;
  };
}
