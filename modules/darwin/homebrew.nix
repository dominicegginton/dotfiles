{ config, lib, ... }:

let
  cfg = config.modules.homebrew;
in

with lib;

{
  options.modules.homebrew = {
    taps = mkStringsOption [ ];
    brews = mkStringsOption [ ];
    casks = mkStringsOption [ ];
    masApps = mkAttrsOption { };
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
