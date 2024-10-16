{ pkgs, mkShell }:

mkShell {
  sopsPGPKeyDirs = [ "./keys" ];
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    ssh-to-pgp
    sops
    pinentry-curses
    archi
  ];
}
