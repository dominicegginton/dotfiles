{...}: {
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.global.lockfiles = false;
  homebrew.taps = ["homebrew/cask-versions"];
  homebrew.brews = [];
  homebrew.casks = [
    # "figma"
    "firefox-developer-edition"
    # "google-chrome-dev"
    # "grammarly-desktop"
    # "slack"
  ];
}
