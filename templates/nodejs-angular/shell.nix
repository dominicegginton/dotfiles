{ pkgs, mkShell, prefetch-npm-deps }:

mkShell {
  inputsFrom = [ pkgs.nodejs-angular ];
  packages = [ prefetch-npm-deps ];
}
