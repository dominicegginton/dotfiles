{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        formatter = pkgs.alejandra;

        packages = rec {
          hello-world = import ./default.nix {
            lib = pkgs.lib;
            python3Packages = pkgs.python3Packages;
          };

          default = hello-world;
        };

        devShells = {
          default = import ./shell.nix {
            inherit pkgs;
          };
        };
      }
    );
}
