{ writeShellApplication, nix, nixos-anywhere, fzf, nmap }:

writeShellApplication {
  name = "bootstrap-nixos-iso-device";
  runtimeInputs = [ nix nixos-anywhere fzf nmap ];
  text = ''
    if [ "$(id -u)" -ne 0 ]; then
      echo "Script must be run as root"
      exit 1
    fi
    temp=$(mktemp -d)
    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT
    hosts=$(nix flake show --json | jq -r '.nixosConfigurations | keys | .[]')
    host=$(echo "$hosts" | tr " " "\n" | fzf --prompt "Select a host: ")
    echo "Scanning network for nixos installer"
    route=$(ip route | grep default | awk '{print $3}')
    ips=$(nmap -sn "$route/24" | grep "Nmap scan report" | awk '{print $5}')
    installer_ip="nixos-installer.local"
    ips=$(echo "$ips" | grep -v "$installer_ip")
    ips="$installer_ip $ips"
    installer_ip=$(echo "$ips" | tr " " "\n" | fzf --prompt "Select the installer IP: ")
    build_on_remote=$(echo "Yes No" | tr " " "\n" | fzf --prompt "Build on remote? ")
    install -d -m755 "$temp/etc/ssh"
    sudo cp /etc/ssh/ssh_host_rsa_key "$temp/etc/ssh/ssh_host_rsa_key"
    sudo cp /etc/ssh/ssh_host_rsa_key.pub "$temp/etc/ssh/ssh_host_rsa_key.pub"
    sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/etc/ssh/ssh_host_ed25519_key"
    sudo cp /etc/ssh/ssh_host_ed25519_key.pub "$temp/etc/ssh/ssh_host_ed25519_key.pub"
    sudo chmod 644 "$temp/etc/ssh/ssh_host_rsa_key.pub"
    sudo chmod 600 "$temp/etc/ssh/ssh_host_rsa_key"
    sudo chmod 644 "$temp/etc/ssh/ssh_host_ed25519_key.pub"
    sudo chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
    if [[ $build_on_remote == "Yes" ]]; then
      nixos-anywhere --build-on-remote --extra-files "$temp" --generate-hardware-config nixos-generate-config "./hosts/nixos/$host/hardware-configuration.nix" --flake ".#$host" "root@$installer_ip"
    else
      nixos-anywhere --extra-files "$temp" --generate-hardware-config nixos-generate-config "./hosts/nixos/$host/hardware-configuration.nix" --flake ".#$host" "root@$installer_ip"
    fi
    nix fmt
  '';
}
