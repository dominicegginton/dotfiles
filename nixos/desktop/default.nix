{ desktop, lib, ... }:

{
  imports = [ ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;
}
