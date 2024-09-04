{ pkgs, nodejs, prefetch-npm-deps }:

pkgs.mkShell {
  inputsFrom = [ pkgs.nodejs-typescript ];
  packages = [ prefetch-npm-deps ];
}
