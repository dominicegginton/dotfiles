{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "i686-linux" "x86_64-darwin"];

    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system: f system);

    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;

        overlays = [self.overlays.default];
      });
  in {
    overlays = {
      default = final: prev: let
        pkgs = final.pkgs;
      in {
        hello-world = import ./default.nix {inherit pkgs;};
      };
    };

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      inherit (pkgs) hello-world;

      default = pkgs.hello-world;
    });

    formatter = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in
        pkgs.alejandra
    );

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = import ./shell.nix {inherit pkgs;};
    });
  };
}
