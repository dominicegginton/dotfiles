{ pkgs, prefetch-npm-deps }:

pkgs.mkShell {
  inputsFrom = [ pkgs.hello-world ];
  packages = [ prefetch-npm-deps ];
}
