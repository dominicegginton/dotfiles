{ lib, writers, coreutils, busybox, git, git-cleanup, ensure-workspace-is-clean, gum }:

writers.writeBashBin "git-sync" ''
  export PATH=${lib.makeBinPath [ coreutils busybox git git-cleanup ensure-workspace-is-clean gum ]}
  set -efu -o pipefail
  ensure-workspace-is-clean
  git fetch --all --prune
  git pull
  original_branch=$(git rev-parse --abbrev-ref HEAD)
  remote_branches=$(git branch -r | grep -v '\->' | grep -v 'HEAD' | awk '{print $1}')
  for remote_branch in $remote_branches; do
    local_branch=$(echo $remote_branch | sed 's/origin\///')
    gum log --level info "Syncing $local_branch"
    if git show-ref --verify --quiet refs/heads/$local_branch; then
      gum log --level info "Pulling $local_branch"
      git checkout $local_branch
      git pull
    else
      gum log --level info "Creating $local_branch"
      git checkout -b $local_branch $remote_branch
    fi
  done
  git checkout $original_branch
  git-cleanup
''
