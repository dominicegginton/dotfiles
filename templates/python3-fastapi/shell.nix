{ mkShell, hello-world, hello-world-oci }:

mkShell {
  inputsFrom = [ hello-world hello-world-oci ];
}
