{ lib, writeShellScriptBin, busybox, coreutils, gum }:

writeShellScriptBin "host-status" ''
  export PATH=${lib.makeBinPath [ busybox coreutils gum ]}
  set -efu -o pipefail
  host=$(echo $(hostname) | gum style --foreground='#6f42c1')
  network=$(ip route | grep default | awk '{print $3}' | xargs -I {} nc -z {} 53 && gum style --foreground='#28a745' "Connected" || gum style --foreground='#d73a49' "Disconnected")
  online=$(nc -z 1.1.1.1 53 && gum style --foreground='#28a745' "Yes" || gum style --foreground='#d73a49' "No")
  ips=$(ip addr | awk '{print $2}' | grep -v "loopback" | grep -v "127" | grep -v "inet6" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$" | tr "\n" " " | sed 's/|$//' | gum style --foreground='#6f42c1')
  username=$(whoami | gum style --foreground='#6f42c1')
  platform=$(uname -s | gum style --foreground='#6f42c1')
  cpu_model=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F ': ' '{print $2}' | gum style --foreground='#6f42c1')
  total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}' | numfmt --to=iec-i --suffix=B | gum style --foreground='#6f42c1')
  msgs=()
  msgs+=("$(gum style --foreground='#0366d6' --align=center --margin="1 0" "NixOS")")
  msgs+=("Hostname: $host")
  msgs+=("Network: $network")
  msgs+=("Online: $online")
  msgs+=("Local addresses: $ips")
  msgs+=("Username: $(echo $username | gum style --foreground='#6f42c1')")
  if "$(whoami)" == "root"; then
    root_password=$(echo "cat /var/shared/root-password)" | gum style --foreground='#d73a49')
    msgs+=("Root password: $root_password")
  fi
  msgs+=("Platform: $platform")
  msgs+=("CPU: $cpu_model")
  msgs+=("RAM: $total_ram")
  gum style --border-foreground='#6f42c1' --border normal "''${msgs[@]}"
''
