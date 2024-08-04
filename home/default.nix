# TODO: tidy this file

{ inputs, lib, username, ... }:

with inputs;
with lib;

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    inputs.nix-index-database.hmModules.nix-index
    inputs.base16.nixosModule
    { scheme = "${inputs.tt-schemes}/base16/primer-light.yaml"; }
    ../modules/home-manager
  ]
  ++ optional (pathExists (./. + "/${username}")) ./${username};
}
