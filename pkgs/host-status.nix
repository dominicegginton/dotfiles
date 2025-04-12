## todo: move to internal module

{ lib, writeShellScriptBin, busybox, coreutils, gum, tailscale }:

writeShellScriptBin "host-status" ''
  export PATH=${lib.makeBinPath [ coreutils busybox gum tailscale ]}
  msgs=()
  msgs+=("$(gum style --foreground='#0366d6' --align=center --margin="1 0" "NixOS")")
  msgs+=("Platform: $(uname -s | gum style --foreground='#6f42c1')")
  msgs+=("Hostname: $(echo $(hostname) | gum style --foreground='#6f42c1')")
  msgs+=("Username: $(whoami | gum style --foreground='#6f42c1')")
  msgs+=("Tailscale IP: $(nc -z 1.1.1.1 53 && tailscale status | grep $(hostname) | awk '{print $1}' | gum style --foreground='#6f42c1' || echo 'Offline' | gum style --foreground='#d73a4a')") 
  msgs+=("CPU: $(cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F ': ' '{print $2}' | gum style --foreground='#6f42c1')")
  msgs+=("RAM: $(grep MemTotal /proc/meminfo | awk '{print $2}' | numfmt --to=iec-i --suffix=B | gum style --foreground='#6f42c1')")
  gum style --border-foreground='#6f42c1' --border normal "''${msgs[@]}"
''
