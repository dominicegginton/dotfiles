{ lib, python3Packages }:

python3Packages.buildPythonApplication {
  pname = "hello-world";
  version = "0.0.0";
  propagatedBuildInputs = with python3Packages; [ fastapi uvicorn ];
  src = lib.sources.cleanSource ./.;
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
