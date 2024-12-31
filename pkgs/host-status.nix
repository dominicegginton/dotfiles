{ lib, writeShellScriptBin, coreutils, busybox, gum }:

let
  paths = lib.makeBinPath [ coreutils busybox gum ];
in

writeShellScriptBin "host-status" ''
  export PATH=${paths}
  set -efu -o pipefail
  ld=$(ip -brief -color addr | awk '{print $3}' | grep -v "lo" | grep -v "127" | tr "\n" " ")
  msgs=()
  msgs+=("$(gum style --foreground=111 --align=center --margin="1 0" "NixOS")")
  user=$(whoami)
  if [ "$user" = "root" && -f /var/shared/root-password ]; then
    msgs+=("Root password: $(cat /var/shared/root-password)")
  fi
  msgs+=("Hostname: $(hostname)")
  msgs+=("Local addresses: $ld")
  msgs+=("Multicast DNS: $(hostname).local")
  gum style --border-foreground=111 --border normal "''${msgs[@]}"
''
