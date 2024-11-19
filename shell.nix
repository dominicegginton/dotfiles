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
    bootstrap-nixos-iso-device
    nixos-anywhere
    install-nixos
  ];
}
