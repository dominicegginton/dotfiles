{
  hostname,
  platform,
  stateVersion,
  pkgs,
  ...
}: {
  imports = [
    ../modules/darwin/system.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/networking.nix
    ../modules/darwin/console.nix
    ../modules/darwin/desktop.nix
    ./${hostname}
  ];

  modules.system.platform = platform;
  modules.system.allowUnfree = true;
  modules.system.stateVersion = stateVersion;
  modules.desktop.enable = false;

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      ibm-plex
    ];
  };
}
