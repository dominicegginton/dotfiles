{ writeShellApplication, coreutils, busybox, nix, nixos-anywhere, fzf, nmap, jq, gum }:

writeShellApplication rec {
  name = "bootstrap-nixos-host";
  runtimeInputs = [ coreutils busybox nix nixos-anywhere fzf nmap jq gum ];
  text = ''
    set -efu -o pipefail
    temp=$(mktemp -d)
    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT
    if [ "$(id -u)" -ne 0 ]; then
      echo "This script must be run as root" 1>&2
      exit 1
    fi
    hostnames=$(nix flake show --json --all-systems | jq -r '.nixosConfigurations | keys | .[]')
    if ! echo "$hostnames" | grep -q "minimal-iso"; then
      echo "This script must be run from the dotfiles flake root directory" 1>&2
      exit 1
    fi
    hostnames=$(echo "$hostnames" | grep -v "minimal-iso")
    hostname=$(echo "$hostnames" | tr " " "\n" | fzf --prompt "Select a hostname: " --height ~100%)
    scan=$(printf "Scan network for installer IP\nUse nixos-installer.local" | fzf --prompt "Select an option: " --height ~100%)
    if [ "$scan" == "Scan network for installer IP" ]; then
      gum spin --show-output --title "Scanning network" -- nmap -sn "$(ip route | grep default | awk '{print $3}')"/24 -oG - | grep "Up" | awk '{print $2}' > "$temp/ips"
      ips=$(cat "$temp/ips")
      rm "$temp/ips"
      installer_ip=$(echo "$ips" | fzf --prompt "Select the installer: " --height ~100% --preview "sleep 1 && nmap -A {}")
    else
      installer_ip="nixos-installer.local"
    fi
    build_target=$(printf "Build on host\nBuild on installer" | fzf --prompt "Select a build target: " --height ~100% | awk '{print $3}')

    install -d -m755 "$temp/root/bitwarden-secrets"
    install -d -m755 "$temp/run/bitwarden-secrets"
    install -d -m755 "$temp/etc"
    cp -r /root/bitwarden-secrets "$temp/root"
    cp -r "$temp/root/bitwarden-secrets" "$temp/run/bitwarden-secrets"
    gum input --password --header "Bitwarden Secrets Project ID" | echo "BWS_PROJECT_ID=$(cat)" >> "$temp/etc/bitwarden-secrets.env"
    gum input --password --header "Bitward Secrets Access Token" | echo "BWS_ACCESS_TOKEN=$(cat)" >> "$temp/etc/bitwarden-secrets.env"
    cat "$temp/etc/bitwarden-secrets.env"

    msg=()
    msg+=("$(gum style --foreground=111 --align=center --width=50 --margin="1 2" --padding="2 4" "NixOS")")
    msg+=("")
    msg+=("Hostname: $hostname")
    msg+=("Installer IP: $installer_ip")
    msg+=( "Build target: $build_target" )
    gum style --border-foreground=111 --border normal "''${msg[@]}"
    gum confirm "Continue with the above configuration?" || exit 1

    if [ "$build_target" == "host" ]; then
      build_cmd="nixos-anywhere"
    else
      build_cmd="nixos-anywhere --build-on-remote"
    fi

    $build_cmd \
      --copy-host-keys \
      --extra-files "$temp" \
      --generate-hardware-config nixos-generate-config "./hosts/nixos/$hostname/hardware-configuration.nix" \
      --flake ".#$hostname" "root@$installer_ip"
  '';
}
