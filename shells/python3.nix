{ lib, mkShell, python3 }:

mkShell {
  name = "ad-hoc python3";
  packages = [ python3 ];
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
