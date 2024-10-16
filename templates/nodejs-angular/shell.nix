{ pkgs, mkShell, prefetch-npm-deps }:

mkShell {
  inputsFrom = [ pkgs.hello-world ];
  packages = [ prefetch-npm-deps ];
}
