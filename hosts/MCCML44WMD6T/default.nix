{pkgs, ...}: {
  modules.networking.enable = true;
  modules.networking.tailscale = true;

  modules.homebrew.enable = true;
  modules.homebrew.casks = [
    "docker" # Docker desktop for Mac
    "firefox-developer-edition" # Firefox developer edition browser
    "google-chrome" # Google Chrome browser
    "chromium" # Chromium browser
    "postman" # Postman API client
  ];
  modules.homebrew.masApps = {
    "Amphetamine" = 937984704; # Keep your Mac awake
    "Xcode" = 497799835; # Xcode IDE for macOS
    "Microsoft To Do" = 1274495053; # Microsoft To Do
    "Resolution Chanager Pro" = 1111438530; # Change the resolution of your Mac
    "Pasteboard Viewer" = 1499215709; # View the contents of your clipboard
  };

  environment.systemPackages = with pkgs; [vscode];
}
