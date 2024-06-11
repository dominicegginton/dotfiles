{ pkgs }:
pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    ssh-to-pgp
    sops
    pinentry-curses
  ];
}
