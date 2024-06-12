{ inputs
, lib
, username
, ...
}:
with lib; {
  imports =
    [
      inputs.nix-colors.homeManagerModules.default
      inputs.nix-index-database.hmModules.nix-index
      ../modules/home-manager
    ]
    ++ optional (pathExists (./. + "/${username}")) ./${username};
}
