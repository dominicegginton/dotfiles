{ pkgs }:

pkgs.writeShellApplication {
  name = "collect-garbage";
  runtimeInputs = with pkgs; [ nix ];

  text = ''
    nix store gc --no-keep-derivations --no-keep-outputs --max 20G
    nix-env --delete-generations +2
    sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
    home-manager expire-generations "-1 days"
    nix store optimise
  '';
}
