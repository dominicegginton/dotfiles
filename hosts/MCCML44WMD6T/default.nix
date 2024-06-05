{pkgs, ...}: {
  modules = {
    homebrew.casks = [
      "docker"
      "firefox-developer-edition"
      "chromium"
      "postman"
    ];
    homebrew.masApps = {
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
      "Microsoft To Do" = 1274495053;
      "Resolution Chanager Pro" = 1111438530;
      "Pasteboard Viewer" = 1499215709;
    };
  };

  environment.systemPackages = with pkgs; [vscode];
}
