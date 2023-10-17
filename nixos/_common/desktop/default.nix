{ desktop, lib, ... }:

{
  imports = [ ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}/desktop.nix")) ./${desktop}/desktop.nix ++ lib.optional (builtins.pathExists (./. + "/${desktop}/apps.nix")) ./${desktop}/apps.nix;
}
