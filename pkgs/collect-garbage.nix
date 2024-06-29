{ pkgs }:

pkgs.writeShellApplication {
  name = "collect-garbage";
  runtimeInputs = with pkgs; [ nix ];

  text = ''
    nix-env --delete-generations old
    nix-collect-garbage --delete-old
    nix-store --optimise
    nix-store --gc
  '';
}
