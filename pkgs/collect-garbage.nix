{ pkgs }:
pkgs.writeShellApplication {
  name = "collect-garbage";

  text = ''
    nix-env --delete-generations old
    nix-collect-garbage --delete-old
    nix-store --optimise
    nix-store --gc
  '';
}
