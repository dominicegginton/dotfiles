{ inputs
, lib
, username
, ...
}:

with inputs;
with lib;

{
  imports = [
    nix-colors.homeManagerModules.default
    nix-index-database.hmModules.nix-index
    ../modules/home-manager
  ]
  ++ optional (pathExists (./. + "/${username}")) ./${username};
}
