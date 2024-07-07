{ pkgs }:

pkgs.writeShellApplication {
  name = "collect-garbage";
  runtimeInputs = with pkgs; [ nix ];

  text = ''
    run_cmd_and_sudo() {
      "$@"
      sudo "$@"
    }

    echo "Collecting garbage..."
    run_cmd_and_sudo nix-collect-garbage
    echo "Optimizing store..."
    run_cmd_and_sudo nix-store --optimise
    echo "Garbage collecting..."
    run_cmd_and_sudo nix store gc
    echo "Deleting old generations..."
    nix-env --delete-generations 2d
    sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations 2d
    home-manager expire-generations "-2 days"
  '';
}
