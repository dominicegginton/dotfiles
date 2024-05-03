{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [
    rustc
    cargo
  ];
}
