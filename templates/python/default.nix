{ pkgs }:

with pkgs.python3Packages;

buildPythonApplication {
  pname = "hello-world";
  version = "0.1.0";
  propagatedBuildInputs = [ flask ];
  src = ./.;
}
