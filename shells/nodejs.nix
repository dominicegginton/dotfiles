{ lib, mkShell, nodejs }:

mkShell {
  name = "ad-hoc nodejs";
  packages = [ nodejs ];
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
