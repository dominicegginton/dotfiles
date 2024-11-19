# bootstap a new nixos system on a remote host
# 1. run the bootstrap-nixos-iso-device script to create a bootable usb
# 2. boot the remote host from the usb
# 3. set a password for the root user with `passwd root`
# 4. connect to a network with the wpa_supplicant service

# 5. run this derivation

{ pkgs, writeShellApplication }:

writeShellApplication {
  name = "install-nixos";
  runtimeInputs = with pkgs; [ nixos-anywhere ];
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

    nixos-anywhere --extra-files "$temp" --flake ".#$hostname" "root@$ip"
  '';
}
