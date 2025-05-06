{ lib, rustPlatform }:

let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in

rustPlatform.buildRustPackage {
  pname = cargoToml.package.name;
  inherit (cargoToml.package) version;
  src = lib.sources.cleanSource ./.;
  cargoHash = lib.fakeHash;
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
