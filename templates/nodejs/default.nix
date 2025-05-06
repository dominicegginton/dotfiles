{ lib, buildNpmPackage }:

let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
in

buildNpmPackage rec {
  pname = packageJson.name;
  inherit (packageJson) version;
  src = lib.sources.cleanSource ./.;
  npmDepsHash = lib.fakeHash;
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
