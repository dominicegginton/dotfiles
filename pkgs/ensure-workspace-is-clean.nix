{ lib, writeShellScriptBin, git, gum }:

writeShellScriptBin "ensure-workspace-is-clean" ''
  export PATH=${lib.makeBinPath [ git gum ]}
  if ! git diff-index --quiet HEAD --; then
    gum log --level error "Workspace is dirty"
    exit 1
  fi
''
