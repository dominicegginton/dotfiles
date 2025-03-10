{ lib, writers, git, gum }:

writers.writeBashBin "ensure-workspace-is-clean" ''
  export PATH=${lib.makeBinPath [ git gum ]}
  if ! git diff-index --quiet HEAD --; then
    gum log --level error "Workspace is dirty"
    exit 1
  fi
''
