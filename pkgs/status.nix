{ lib, writeShellScriptBin, busybox, coreutils, gum, tailscale }:

writeShellScriptBin "status" ''
  export PATH=${lib.makeBinPath [ coreutils busybox gum tailscale ]}
  router_ip=$(ip route | grep default | awk '{print $3}' || echo "")
  dns_ip=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' || echo "")
  msgs=()
  msgs+=("$(uname -o | gum style --foreground='0366d6' --bold --padding='1 0')")
  msgs+=("Username: $(whoami | gum style --foreground='#7f42c1')")
  msgs+=("Hostname: $(hostname | gum style --foreground='#7f42c1')")
  msgs+=("CPU: $(cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F ': ' '{print $2}' | gum style --foreground='#6f42c1')")
  msgs+=("RAM: $(grep MemTotal /proc/meminfo | awk '{print $2}' | numfmt --to=iec-i --suffix=B | gum style --foreground='#6f42c1')")
  msgs+=("Network connection: $(nc -zv $router_ip 80 2>&1 | gum style --foreground='#008000' || echo "Offline" | gum style --foreground='#ff0000')")
  msgs+=("Internet connection: $(nc -zv $dns_ip 53 2>&1 | gum style --foreground='#008000' || echo "Offline" | gum style --foreground='#ff0000')")
  msgs+=("Network: $(echo $(hostname) | gum style --foreground='#008000') - $(hostname -i | gum style --foreground='#008000')")
  msgs+=("Tailscale: $(tailscale status | grep $(hostname) | awk '{print $2}' | gum style --foreground='#008000') - $(tailscale status | grep $(hostname) | awk '{print $1}' | gum style --foreground='#008000')") 
  gum style --padding="1 2" --border-foreground='#0366d6' --border normal "''${msgs[@]}"
''
