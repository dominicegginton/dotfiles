{ lib, writeShellScriptBin, coreutils, gum }:

writeShellScriptBin "ensure-user-is-root" ''
  export PATH=${lib.makeBinPath [ coreutils gum ]}
  if [ "$(id -u)" != "0" ]; then
    ${gum}/bin/gum log --level error "must be run as root"
    exit 1
  fi
''
