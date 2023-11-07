{...}: {
  homebrew.enable = true;
  homebrew.brewPrefix = "/usr/local/bin/brew";
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.global.lockfiles = false;
  homebrew.taps = [];
  homebrew.brews = [];
  homebrew.casks = [
    # "figma"
    # "firefox-developer-edition"
    # "google-chrome-dev"
    # "grammarly-desktop"
    # "slack"
  ];
}
