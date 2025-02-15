{ lib, stdenv, writers, ensure-user-is-root, coreutils, git, busybox, nix, nixos-anywhere, fzf, nmap, jq, gum, bws }:

if (!stdenv.isLinux)
then throw "This script can only be run on linux hosts"
else

  let
    directory = "$temp/root/bitwarden-secrets";
    mountpoint = "$temp/run/bitwarden-secrets";
  in

  writers.writeBashBin "bootstrap-nixos-hosts" ''
    export PATH=${lib.makeBinPath [ ensure-user-is-root coreutils git busybox nix nixos-anywhere fzf nmap jq gum bws ]}
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
    mkdir -p ${directory} || true
    mkdir -p ${directory}/secrets || true
    mkdir -p ${mountpoint} || true
    mkdir -p ${mountpoint}/secrets || true
    chmod 700 ${directory}
    chmod 700 ${directory}/secrets
    chmod 700 ${mountpoint}
    chown root:root ${directory}
    chown root:root ${directory}/secrets
    chown root:root ${mountpoint}
    source /root/bitwarden-secrets/secrets.env
    gum spin \
      --show-output \
      --title "Syncing secrets from Bitwarden Secrets $BWS_PROJECT_ID" \
      -- bws secret list "$BWS_PROJECT_ID" \
        --output json \
        --access-token "$BWS_ACCESS_TOKEN" \
        > "${directory}/secrets.json"
    for id in $ids; do
      name=$(jq -r ".[] | select(.id == \"$id\") | .name" ${directory}/secrets.json)
      value=$(jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      echo $value | sed 's/\\n/\n/g' > ${directory}/secrets/$name
      chown root:root ${directory}/secrets/$name
      chmod 700 ${directory}/secrets/$name
      ln -sf ${directory}/secrets/$name ${mountpoint}/secrets/$name
      chown root:root ${mountpoint}/secrets/$name
      chmod 700 ${mountpoint}/secrets/$name
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
