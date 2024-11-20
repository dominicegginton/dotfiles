{ writeShellApplication }:

writeShellApplication {
  name = "install-nixos";
  text = ''
    set -e

    if [ "$#" -ne 2 ]; then
      echo "Usage: $0 <ip> <hostname>"
      exit 1
    fi

    ip=$1
    hostname=$2

    temp=$(mktemp -d)

    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT

    install -d -m755 "$temp/etc/ssh"

    sudo cp /etc/ssh/ssh_host_rsa_key "$temp/etc/ssh/ssh_host_rsa_key"
    sudo cp /etc/ssh/ssh_host_rsa_key.pub "$temp/etc/ssh/ssh_host_rsa_key.pub"
    sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/etc/ssh/ssh_host_ed25519_key"
    sudo cp /etc/ssh/ssh_host_ed25519_key.pub "$temp/etc/ssh/ssh_host_ed25519_key.pub"
    sudo chmod 644 "$temp/etc/ssh/ssh_host_rsa_key.pub"
    sudo chmod 600 "$temp/etc/ssh/ssh_host_rsa_key"
    sudo chmod 644 "$temp/etc/ssh/ssh_host_ed25519_key.pub"
    sudo chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

    sudo nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --generate-hardware-config nixos-generate-config "./hosts/nixos/$hostname/hardware-configuration.nix" --flake ".#$hostname" "root@$ip"
  '';
}
