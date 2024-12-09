{ writeShellApplication, nix, home-manager }:

writeShellApplication {
  name = "collect-garbage";
  runtimeInputs = [ nix home-manager ];
  text = ''
    sudo -v
    nix store gc
    nix-env --delete-generations +2
    nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
    home-manager expire-generations "-1 days"
    nix store optimise
  '';
}
