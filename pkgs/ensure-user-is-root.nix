{ writers, gum }:

writers.writeBashBin "ensure-user-is-root" ''
  if [ "$(id -u)" != "0" ]; then
    ${gum}/bin/gum log --level error "must be run as root"
    exit 1
  fi
''
