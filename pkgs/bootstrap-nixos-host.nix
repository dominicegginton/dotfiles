{ writeShellApplication, nix, nixos-anywhere, fzf, nmap, jq, busybox }:

writeShellApplication {
  name = "bootstrap-nixos-host";
  runtimeInputs = [ nix nixos-anywhere fzf nmap jq busybox ];
  text = ''
    if [ "$(id -u)" -ne 0 ]; then
      echo "This script must be run as root" 1>&2
      exit 1
    fi
    temp=$(mktemp -d)
    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT
    install -d -m755 "$temp/root/bitwarden-secrets"
    sudo cp -r /root/bitwarden-secrets "$temp/root/bitwarden-secrets"
    chown -R root:root "$temp/root/bitwarden-secrets"
    chmod -R 700 "$temp/root/bitwarden-secrets"
    hosts=$(nix flake show --json | jq -r '.nixosConfigurations | keys | .[]' | grep -v minimal-iso)
    host=$(echo "$hosts" | tr " " "\n" | fzf --prompt "Select a configuration: ")
    echo "[bootstap-nixos-host] Scanning network for nixos installer"
    route=$(ip route | grep default | awk '{print $3}')
    ips=$(nmap -sn "$route/24" | grep "Nmap scan report" | awk '{print $5}')
    installer_ip=$(echo "$ips" | tr " " "\n" | fzf --print-query --prompt "Select the installer IP: ")
    nixos-anywhere --build-on-remote --extra-files "$temp" --generate-hardware-config nixos-generate-config "./hosts/nixos/$host/hardware-configuration.nix" --flake ".#$host" "root@$installer_ip"
    nix fmt
  '';
}
