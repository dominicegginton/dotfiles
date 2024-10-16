{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:

    with flake-utils.lib;

    eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (final: _: { hello-world = final.callPackage ./default.nix { }; }) ];
        };
      in

      {
        formatter = pkgs.nixpkgs-fmt;
        packages.hello-world = pkgs.hello-world;
        packages.default = pkgs.hello-world;
        devShells.default = pkgs.callPackage ./shell.nix { };
      }
    );
}
