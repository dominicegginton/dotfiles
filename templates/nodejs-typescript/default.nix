{ lib, buildNpmPackage, importNpmLock }:

let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
in

buildNpmPackage rec {
  pname = packageJson.name;
  inherit (packageJson) version;
  src = lib.sources.cleanSource ./.;
  npmConfigHook = importNpmLock.npmConfigHook;
  npmDeps = importNpmLock { npmRoot = src; };
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
