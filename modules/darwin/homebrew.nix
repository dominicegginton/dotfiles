{ config, lib, ... }:

let
  cfg = config.modules.homebrew;
in

with lib;

{
  options.modules.homebrew = {
    taps = mkOption { type = types.listOf types.str; default = [ ]; };
    brews = mkOption { type = types.listOf types.str; default = [ ]; };
    casks = mkOption { type = types.listOf types.str; default = [ ]; };
    masApps = mkOption { type = types.attrs; default = { }; };
  };

  config = {
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
