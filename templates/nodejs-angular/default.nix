{ lib, buildNpmPackage }:

let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
in

buildNpmPackage {
  pname = packageJson.name;
  inherit (packageJson) version;
  src = lib.sources.cleanSource ./.;
  npmDepsHash = "sha256-426gvVsB26fQyisFXKOuF0b8BSvCeEEZPn+Wop+R+is=";
  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out
  '';
}
