{ lib, buildDotnetModule }:

buildDotnetModule {
  pname = "hello-world";
  version = "0.0.0";
  src = lib.sources.cleanSource ./.;
  projectFile = "hello-world/hello-world.csproj";
}
