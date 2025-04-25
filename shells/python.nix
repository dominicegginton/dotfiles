{ lib, mkShell, python3 }:

mkShell {
  name = "ad-hoc python";
  packages = [ (python3.withPackages (pythonPkgs: with pythonPkgs; [ ])) ];
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
