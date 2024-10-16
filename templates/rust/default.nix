{ lib, rustPlatform }:

let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in

rustPlatform.buildRustPackage {
  pname = cargoToml.package.name;
  version = cargoToml.package.version;
  src = lib.sources.cleanSource ./.;
  cargoSha256 = "sha256-CTjTUz8twqUz7OK6vZKmQRbAhX78C7cYbZY2dMfuXAs=";
}
