{ pkgs, mkShell }:

mkShell {
  inputsFrom = [ pkgs.hello-world ];
}
