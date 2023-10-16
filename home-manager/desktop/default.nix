{ desktop, lib, username, ... }: {
  imports = [
    (./. + "/${desktop}.nix")
  ] ++ lib.optional (builtins.pathExists (./. + "/../users/${username}/desktop.nix")) ../users/${username}/desktop.nix;
}
