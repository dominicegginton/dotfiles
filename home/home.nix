{ inputs
, lib
, username
, ...
}:

with inputs;
with lib;

{
  imports = [
    nix-index-database.hmModules.nix-index
    inputs.base16.nixosModule
    { scheme = "${inputs.tt-schemes}/base16/windows-10.yaml"; }
    ../modules/home-manager
  ]
  ++ optional (pathExists (./. + "/${username}")) ./${username};
}
