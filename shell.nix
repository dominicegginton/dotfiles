{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    ssh-to-pgp
    sops
    pinentry-curses
  ];
}
