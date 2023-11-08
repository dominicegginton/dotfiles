{
  lib,
  desktop,
  ...
}: let
  inherit (lib) optional;
  inherit (builtins) pathExists;
in {
  imports =
    []
    ++ optional (pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;
}
