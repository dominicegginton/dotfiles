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
    generations=$(home-manager generations | awk '{print $5}' | tail -n +3)
    echo "home-generations=$generations"
    delete_generations() {
      for generation in $@; do
        home-manager remove-generation $generation
      done
    }
    if [ -n "$home-generations" ]; then
      gum spin --show-output --title "Deleting old home-manager generations..." -- delete_generations $generations
    else
      gum log --info "No home-manager generations to delete"
    fi
  else
    gum spin --show-output --title "Deleting old generations..." -- nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
  fi
''
