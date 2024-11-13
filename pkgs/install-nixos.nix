# bootstap a new nixos system on a remote host
# 1. run the bootstrap-nixos-iso-device script to create a bootable usb
# 2. boot the remote host from the usb
# 3. set a password for the root user with `passwd root`
# 4. connect to a network with the wpa_supplicant service

# 5. run this derivation

{ pkgs }:

pkgs.writeShellApplication {
  name = "install-nixos";

  runtimeInputs = with pkgs; [ openssh sops ssh-to-age ];

  text = ''
    hostname=$1
    ip=$2

    if [ -z "$hostname" ] || [ -z "$ip" ]; then
      echo "Usage: $0 <hostname> <ip>"
      exit 1
    fi

    temp=$(mktemp -d)
    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT

    install -d -m755 "$temp/etc/ssh"
    ssh-keygen -t ed25519 -f "$temp/etc/ssh/ssh_host_ed25519_key"
    ssh-to-age -i "$temp/etc/ssh/ssh_host_ed25519_key" -o "$temp/etc/ssh/ssh_host_ed25519_key.age"
    chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

    nix run github:nix-community/nixos-anywhere#nixos-anywhere -- --extra-files "$temp" --flake ".#$hostname" root@"$ip"
  '';
}
