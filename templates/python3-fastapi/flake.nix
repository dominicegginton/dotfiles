{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.dotfiles.url = "github:dominicegginton/dotfiles";

  outputs = { nixpkgs, dotfiles, ... }:

    dotfiles.lib.eachPlatform nixpkgs.lib.platforms.all (platform:

      let
        pkgs = import nixpkgs {
          system = platform;
          overlays = [
            dotfiles.overlays.default
            (final: _: {
              hello-world = final.callPackage ./default.nix { };
              hello-world-oci = final.callPackage ./oci.nix { };
            })
          ];
        };
      in

      {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          inherit (pkgs) hello-world hello-world-oci;
          default = pkgs.hello-world;
        };
        devShells.default = pkgs.callPackage ./shell.nix { };
      }
    );
}
