## todo: move to internal module

{ lib, writeShellScriptBin, busybox, coreutils, gum }:

writeShellScriptBin "host-status" ''
  export PATH=${lib.makeBinPath [ coreutils busybox gum ]}
  set -efu -o pipefail
  host=$(echo $(hostname) | gum style --foreground='#6f42c1')
  network=$($(ip route | grep default | awk '{print $3}' | xargs -I {} nc -z {} 53 ) && gum style --foreground='#28a745' "Connected" || gum style --foreground='#d73a49' "Disconnected")
  online=$(nc -z 1.1.1.1 53 && gum style --foreground='#28a745' "Yes" || gum style --foreground='#d73a49' "No")
  username=$(whoami | gum style --foreground='#6f42c1')
  platform=$(uname -s | gum style --foreground='#6f42c1')
  cpu_model=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F ': ' '{print $2}' | gum style --foreground='#6f42c1')
  total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}' | numfmt --to=iec-i --suffix=B | gum style --foreground='#6f42c1')
  msgs=()
  msgs+=("$(gum style --foreground='#0366d6' --align=center --margin="1 0" "NixOS")")
  msgs+=("Hostname: $host")
  msgs+=("Username: $username")
  msgs+=("Network: $network")
  msgs+=("Online: $online")
  msgs+=("Username: $(echo $username | gum style --foreground='#6f42c1')")
  msgs+=("Platform: $platform")
  msgs+=("CPU: $cpu_model")
  msgs+=("RAM: $total_ram")
  gum style --border-foreground='#6f42c1' --border normal "''${msgs[@]}"
''
