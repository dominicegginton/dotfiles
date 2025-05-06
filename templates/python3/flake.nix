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
            (final: _: { hello-world = final.callPackage ./default.nix { }; })
          ];
        };
      in

      {
        formatter = pkgs.nixpkgs-fmt;
        packages.default = pkgs.hello-world;
        packages.hello-world = pkgs.hello-world;
        devShells.default = pkgs.callPackage ./shell.nix { };
      }
    );
}


