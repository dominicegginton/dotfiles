{ lib, buildNpmPackage }:

let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
in

buildNpmPackage {
  pname = packageJson.name;
  inherit (packageJson) version;
  src = lib.sources.cleanSource ./.;
  npmDepsHash = "sha256-fQur3bmag0vBa4VZU3EL8+2Vvhq+tsKgLSzBNfuEkw4=";
}
