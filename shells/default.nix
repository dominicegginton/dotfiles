{
  inputs,
  pkgs,
  platform,
}: let
  NIX_CONFIG = "experimental-features = nix-command flakes";
  developmentPkgs = with pkgs; [
    git
    gitAndTools.git-crypt
    gitAndTools.git-lfs
    gh
  ];
in {
  python = import ./python.nix {inherit NIX_CONFIG pkgs developmentPkgs;};
  rust = import ./rust.nix {inherit NIX_CONFIG pkgs developmentPkgs;};
  web = import ./web.nix {inherit NIX_CONFIG pkgs developmentPkgs;};
  default = import ./workspace.nix {inherit inputs NIX_CONFIG pkgs developmentPkgs platform;};
}
