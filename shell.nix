{ pkgs, mkShell }:

mkShell {
  nativeBuildInputs = with pkgs; [
    nix
    bootstrap-nixos-iso-device
    bootstrap-nixos-host
    collect-garbage
    secrets-sync
  ];
}
