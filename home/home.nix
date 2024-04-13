{
  inputs,
  lib,
  username,
  ...
}:
with lib; {
  imports =
    [
      inputs.nix-colors.homeManagerModules.default
      inputs.nix-index-database.hmModules.nix-index
      ../modules/home-manager/system.nix
      ../modules/home-manager/console.nix
      ../modules/home-manager/desktop.nix
    ]
    ++ optional (pathExists (./. + "/${username}")) ./${username};
}
