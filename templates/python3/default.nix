{ pkgs, lib }:

pkgs.python3Packages.buildPythonApplication {
  pname = "hello-world";
  version = "0.0.0";
  src = lib.sources.cleanSource ./.;
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
