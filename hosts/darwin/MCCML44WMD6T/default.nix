{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ vscode ];

  modules.homebrew.casks = [ "docker" "postman" "firefox-developer-edition" "chromium" ];
  modules.homebrew.masApps = {
    "Amphetamine" = 937984704;
    "Xcode" = 497799835;
    "Microsoft To Do" = 1274495053;
    "Resolution Chanager Pro" = 1111438530;
    "Pasteboard Viewer" = 1499215709;
  };
}
