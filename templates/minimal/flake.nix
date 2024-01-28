{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    flake-utils,
  }:
    flake-utils.lib.eachSystem (import systems)
    (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;

      devShells = {
        default = pkgs.mkShell rec {
          NIX_CONFIG = "experimental-features = nix-command flakes";
          buildInputs = with pkgs; [];
        };
      };
    });
}
