{...}: {
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.global.lockfiles = false;
  homebrew.taps = ["homebrew/cask-versions"];
  homebrew.brews = [];
  homebrew.casks = [
    "docker"
    "firefox-developer-edition"
    "google-chrome"
  ];
}
