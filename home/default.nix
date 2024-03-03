{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; {
  imports =
    [
      inputs.nix-colors.homeManagerModules.default
      ../modules/home-manager/system.nix
      ../modules/home-manager/console.nix
      ../modules/home-manager/desktop.nix
    ]
    ++ optional (pathExists (./. + "/${username}")) ./${username};
}
