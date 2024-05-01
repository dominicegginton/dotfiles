{pkgs}:
with pkgs;
  writeShellApplication rec {
    name = "cleanup-trash";
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
      nix-store --gc
      echo "Would you like to remove all old Nix system profiles generations? (y/n)"
      read -r confirm
      if [ "$confirm" != "y" ]; then
        nix-env -p /nix/var/nix/profiles/system --delete-generations +5
      fi
    '';
  }
