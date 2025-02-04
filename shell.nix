{ pkgs, mkShell }:

mkShell {
  nativeBuildInputs = with pkgs; [
    (lib.development-promt "dominicegginton/dotfiles")
    nix
    bootstrap-nixos-host
    bootstrap-nixos-installer
    collect-garbage
    git-cleanup
    git-sync
    gpg-import-keys
    host-status
  ];
}
