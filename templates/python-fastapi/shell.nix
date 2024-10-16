{ pkgs, mkShell }:

mkShell {
  inputsFrom = [ pkgs.python-fastapi.pkg ];
}
