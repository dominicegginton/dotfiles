{ hostname
, platform
, stateVersion
, pkgs
, ...
}:

{
  imports = [
    ../modules/darwin/system.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/networking.nix
    ../modules/darwin/console.nix
    ../modules/darwin/desktop.nix
    ./${hostname}
  ];

  modules.system.platform = platform;
  modules.system.stateVersion = stateVersion;
}
