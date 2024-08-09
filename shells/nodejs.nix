{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    typescript
    nodePackages.typescript-language-server
  ];
}
