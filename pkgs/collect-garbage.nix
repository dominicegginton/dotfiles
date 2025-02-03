{ lib, writers, busybox, nix, home-manager, gum }:

writers.writeBashBin "collect-garbage" ''
  export PATH=${lib.makeBinPath [ busybox nix home-manager gum ]}
  set -efu -o pipefail
  nix store info
  gum spin --show-output --title "Collecting garbage..." -- nix store gc
  gum spin --show-output --title "Deleting old generations..." -- nix-env --delete-generations +2
  gum spin --show-output --title "Optimising store..." -- nix store optimise
  user=$(whoami)
  if [ "$user" != "root" ]; then
    gum spin --show-output --title "Collecting garbage..." -- home-manager expire-generations --keep '-2d'
  else
    gum spin --show-output --title "Deleting old generations..." -- nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
  fi
''
