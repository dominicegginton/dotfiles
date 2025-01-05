{ pkgs, mkShell }:

mkShell {
  nativeBuildInputs = with pkgs; [
    nix
    bootstrap-nixos-host
    bootstrap-nixos-iso-device
    collect-garbage
    git-cleanup
    git-sync
    gpg-import-keys
    host-status
    secrets-sync
  ];
}
