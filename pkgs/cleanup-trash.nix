{pkgs, ...}:
pkgs.writeShellApplication rec {
  name = "cleanup-trash";

  runtimeInputs = with pkgs; [nix docker];

  text = ''
    set -euo pipefail

    echo "This script will delete all generations of Nix and garbage collect the store."
    echo "Are you sure you want to continue? (y/n)"
    read -r confirm
    if [ "$confirm" != "y" ]; then
      echo "Aborting."
      exit 1
    fi

    nix-env --delete-generations old
    nix-collect-garbage
    nix-collect-garbage -d
    nix-store --gc --print-dead

    docker system prune -a
    docker volume prune --volumes
  '';
}
