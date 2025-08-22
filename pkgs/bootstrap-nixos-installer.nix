{ lib, writeShellScriptBin, busybox, coreutils, gum, tailscale }:

## script to bootstrap a NixOS iso installer image
## this iso can be build from github:dominicegginton/dotfiles#nixos-installer

writeShellScriptBin "bootstrap-nixos-installer" ''
  export PATH=${lib.makeBinPath [ coreutils busybox gum tailscale ]}

    set -euo pipefail
    IFS=$'\n\t'
    gum style --foreground 212 --border-foreground 212 --border double --padding "1 2" --margin "1 2" --align center "NixOS Installer Bootstrapper"

''
