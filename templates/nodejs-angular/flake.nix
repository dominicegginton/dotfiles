{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:

    with flake-utils.lib;

    eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ (final: _: { nodejs-angular = final.callPackage ./default.nix { }; }) ];
        };
      in

      {
        formatter = pkgs.nixpkgs-fmt;
        packages.default = pkgs.nodejs-angular;
        devShells.default = pkgs.callPackage ./shell.nix { };
      }
    );
}