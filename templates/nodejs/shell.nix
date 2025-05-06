{ mkShell, hello-world }:

mkShell {
  inputsFrom = [ hello-world ];
}
