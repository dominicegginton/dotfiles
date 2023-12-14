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
  homebrew.masApps = {
    "Afinity Photo" = 824183456;
    "Afinity Designer" = 824171161;
    "Amphetamine" = 937984704;
    "Xcode" = 497799835;
    "Developer" = 640199958;
    "Microsoft To Do" = 1274495053;
    "Resolution Chanager Pro" = 1111438530;
    "Pasteboard Viewer" = 1499215709;
    "TestFlight" = 899247664;
    "Transporter" = 1450874784;
  };
}
