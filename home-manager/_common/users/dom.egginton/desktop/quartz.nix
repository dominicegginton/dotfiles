{ config, lib, ... }:

{
  homebrew.brewPrefix = "/opt/homebrew/bin";

  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.enable = true;

  homebrew.global.brewfile = true;
  homebrew.global.lockfiles = false;

  homebrew.taps = [ ];

  homebrew.brews = [ ];

  homebrew.casks = [
    "figma"
    "firefox-developer-edition"
    "google-chrome-dev"
    "grammarly-desktop"
    "slack"
  ];
}
