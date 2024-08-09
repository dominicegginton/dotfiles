{ pkgs, nodejs, prefetch-npm-deps }:

pkgs.mkShell {
  packages = [ nodejs prefetch-npm-deps ];
}
