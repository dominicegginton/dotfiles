{
  inputs,
  outputs,
  hostname,
  username,
  platform,
  stateVersion,
  pkgs,
  ...
}: {
  imports = [
    ../modules/darwin/system.nix
    ../modules/darwin/homebrew.nix
    ../modules/nixos/system.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/console.nix
    ../modules/nixos/desktop.nix
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
