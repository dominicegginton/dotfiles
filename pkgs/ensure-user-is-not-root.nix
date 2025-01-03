
{ lib, writers, coreutils, gum }:

writers.writeBashBin "ensure-user-is-not-root" ''
  export PATH=${lib.makeBinPath [ coreutils gum ]}
  if [ "$(id -u)" = "0" ]; then
    ${gum}/bin/gum log --level error "must not be run as root"
    exit 1
  fi
''
