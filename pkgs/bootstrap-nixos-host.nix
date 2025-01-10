{ lib, stdenv, writers, ensure-user-is-root, coreutils, git, busybox, nix, nixos-anywhere, fzf, nmap, jq, gum, secrets-sync }:

if (!stdenv.isLinux)
then throw "This script can only be run on linux hosts"
else

  writers.writeBashBin "bootstrap-nixos-hosts" ''
    export PATH=${lib.makeBinPath [ ensure-user-is-root coreutils git busybox nix nixos-anywhere fzf nmap jq gum secrets-sync ]}
    set -efu -o pipefail
    ensure-user-is-root
    temp=$(mktemp -d)
    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT
    hostname=$(nix flake show --json --all-systems | jq -r '.nixosConfigurations | keys | .[]' | grep -v "nixos-installer" | tr " " "\n" | fzf --prompt "Select a hostname: " --height ~100%)
    gum spin \
      --show-output \
      --title "Scanning network" \
      -- nmap -sn "$(ip route | grep default | awk '{print $3}')"/24 -oG - | grep "Up" | awk '{print $2}' > "$temp/ips"
    ips=$(cat "$temp/ips")
    rm "$temp/ips"
    installer_ip=$(echo "$ips" | fzf --prompt "Select the installer: " --height ~100% --preview "sleep 1 && nmap -A {}")
    build_target=$(printf "host\nremote" | fzf --prompt "Select a build target: " --height ~100%)
    gum confirm "Would you like to sync secrets before copying them to the installer?" && secrets-sync
    mkdir -p "$temp/root/bitwarden-secrets"
    mkdir -p "$temp/run/bitwarden-secrets"
    chown -R root:root "$temp/root/bitwarden-secrets"
    chown -R root:root "$temp/run/bitwarden-secrets"
    chmod -R 700 "$temp/root/bitwarden-secrets"
    chmod -R 700 "$temp/run/bitwarden-secrets"
    cp -r /root/bitwarden-secrets "$temp/root"
    secrets=$(find "$temp/root/bitwarden-secrets/secrets" -type f)
    for secret in $secrets; do
      name=$(basename "$secret")
      cp "$secret" "$temp/run/bitwarden-secrets/$name"
      chown root:root "$temp/run/bitwarden-secrets/$name"
      chmod 600 "$temp/run/bitwarden-secrets/$name"
    done
    msg=()
    msgs+=("$(gum style --foreground=111 --align=center --margin="1 0" "NixOS")")
    msg+=("Hostname: $hostname")
    msg+=("Installer IP: $installer_ip")
    msg+=( "Build target: $build_target" )
    msg+=("Temp directory size: $(du -sh "$temp" | awk '{print $1}')")
    gum style --border-foreground=111 --border normal "''${msg[@]}"
    gum confirm "Continue with the above configuration?" || exit 1
    if [ "$build_target" == "host" ]; then
      build_cmd="nixos-anywhere"
    else
      build_cmd="nixos-anywhere --build-on-remote"
    fi
    $build_cmd \
      --extra-files "$temp" \
      --generate-hardware-config nixos-generate-config "./hosts/nixos/$hostname/hardware-configuration.nix" \
      --flake ".#$hostname" "root@$installer_ip"
  ''
