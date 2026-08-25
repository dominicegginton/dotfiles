{
  self,
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

let
  # Helper script to display IP address, root password, QR code, and deployment command
  installerInfo = pkgs.writeShellScriptBin "installer-info" ''
    IP_ADDR="$(${pkgs.iproute2}/bin/ip -4 addr show scope global | ${pkgs.gnugrep}/bin/grep -oP '(?<=inet\s)\d+(\.\d+){3}' | ${pkgs.coreutils}/bin/head -n1 || echo "No IP detected")"
    ROOT_PASS="$(${pkgs.coreutils}/bin/cat /var/shared/root-password 2>/dev/null || echo "unknown")"

    ${pkgs.gum}/bin/gum style \
      --border double \
      --margin "1 0" \
      --padding "1 2" \
      --border-foreground 212 \
      "Target IP Address: $IP_ADDR
    Root Password:     $ROOT_PASS
    SSH Destination:   root@$IP_ADDR"

    if [ "$IP_ADDR" != "No IP detected" ]; then
      ${pkgs.gum}/bin/gum style --foreground 214 "Scan QR Code for SSH target destination (root@$IP_ADDR):"
      echo ""
      ${pkgs.qrencode}/bin/qrencode -t UTF8 "root@$IP_ADDR" || true
      echo ""
      ${pkgs.gum}/bin/gum style \
        --border normal \
        --margin "0 0 1 0" \
        --padding "0 1" \
        --border-foreground 82 \
        "Deploy from your host machine with: deploy-host <hostname> root@$IP_ADDR"
    fi
  '';
in

{
  # Base installer image
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

  image.baseName = lib.mkDefault "${config.nixos.distroId}-installer";

  console.earlySetup = true;

  # Enable SSH for remote access during installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  # Authorize maintainer SSH keys for root on the live ISO installer
  users.users.root.openssh.authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;

  # Auto-login as root for ease of use
  services.getty.autologinUser = lib.mkForce "root";

  networking.tempAddresses = "disabled";

  # Create a shared directory for password transfer
  systemd.tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];

  # Generate a random root password and store it in /var/shared
  system.activationScripts.root-password = ''
    mkdir -p /var/shared
    ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
    echo "root:$(cat /var/shared/root-password)" | chpasswd
  '';

  # Installer info helper script to show IP, root password, QR code, and deploy-host command
  environment.systemPackages = [ installerInfo ];

  # Automatically display installer info upon root login on TTY
  environment.interactiveShellInit = ''
    if [ "$(id -u)" -eq 0 ] && [ -t 0 ]; then
      installer-info
    fi
  '';

  # Disable Beszel monitoring for the installer
  services.beszel.enable = lib.mkForce false;
}
