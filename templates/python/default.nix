{ python3Packages }:
with python3Packages;
buildPythonApplication {
  pname = "hello-world";
  version = "0.1.0";
  propagatedBuildInputs = [ flask ];
  src = ./.;
}
