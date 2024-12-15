{ writeShellApplication, nix, home-manager }:

writeShellApplication {
  name = "collect-garbage";
  runtimeInputs = [ nix home-manager ];
  text = ''
    if [ "$(id -u)" != "0" ]; then
      echo "This script must be run as root" 1>&2
      exit 1
    fi
    nix store gc
    nix-env --delete-generations +2
    nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
    home-manager expire-generations "-1 days"
    nix store optimise
  '';
}
