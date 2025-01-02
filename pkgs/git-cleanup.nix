{ lib, writers, coreutils, busybox, git, ensure-workspace-is-clean, gum }:

writers.writeBashBin "git-cleanup" ''
  export PATH=${lib.makeBinPath [ coreutils busybox git ensure-workspace-is-clean gum ]}
  set -efu -o pipefail
  ensure-workspace-is-clean
  git fetch --all --prune
  branches=$(git branch --merged | grep -v "\*" | xargs -n 1)
  if [ -z "$branches" ]; then
    gum log --info "No branches to delete"
    exit 0
  fi
  msgs=()
  msgs+=("Branches to delete:")
  for branch in $branches; do
    msgs+=("$branch")
  done
  gum style --border-foreground=111 --border normal "''${msgs[@]}"
  gum confirm "Delete the above branches?" || exit 1
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
''
