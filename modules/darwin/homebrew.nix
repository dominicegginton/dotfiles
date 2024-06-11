{ config
, lib
, ...
}:
with lib; let
  cfg = config.modules.homebrew;
in
{
  options.modules.homebrew.taps = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  options.modules.homebrew.brews = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  options.modules.homebrew.casks = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  options.modules.homebrew. masApps = mkOption {
    type = types.attrs;
    default = { };
  };

  config = mkIf cfg.enable {
    homebrew.onActivation.autoUpdate = true;
    homebrew.onActivation.cleanup = "zap";
    homebrew.global.brewfile = true;
    homebrew.global.lockfiles = false;
    homebrew.taps = [ "homebrew/cask-versions" ] ++ cfg.taps;
    homebrew.brews = cfg.brews;
    homebrew.casks = cfg.casks;
    homebrew.masApps = cfg.masApps;
  };
}
