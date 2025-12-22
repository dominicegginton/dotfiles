{ lib, pkgs, modulesPath, ... }:

let
  installerName = builtins.getEnv "RESIDENCE_INSTALLER_NAME";
in

# assert installerName != "";  # Ensure

let
  installer = pkgs.writeShellScriptBin "residence-installer" ''
    echo "This is the Residence installer."
    echo "${installerName}"
  '';
in

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];

  image.baseName = lib.mkDefault "residence-installer";
  console.earlySetup = true;

  services = {
    openssh.enable = true;
    getty.autologinUser = lib.mkForce "root";
    tailscale.enable = true;
  };

  programs.bash.interactiveShellInit = ''
    if [[ "$(tty)" =~ /dev/(tty1|hvc0|ttyS0)$ ]]; then
      systemctl restart systemd-vconsole-setup.service
      # Display network status
      ${pkgs.iproute2}/bin/ip -c addr
    fi
  '';

  systemd = {
    services.log-network-status = {
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "journal+console";
        ExecStart = [
          "-${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online"
          "${pkgs.iproute2}/bin/ip -c addr"
          "${pkgs.iproute2}/bin/ip -c -6 route"
          "${pkgs.iproute2}/bin/ip -c -4 route"
          "${pkgs.systemd}/bin/networkctl status"
        ];
      };
    };
    tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];
  };

  system.activationScripts.root-password = ''
    mkdir -p /var/shared
    ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
    echo "root:$(cat /var/shared/root-password)" | chpasswd
  '';

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "install" ''
      set -eux

      # TODO: test network connectivity and exit if not online
      # TODO: import gpg key for scrects decryption (root user)

      # Get available configurations from the flake
      ${pkgs.gum}/bin/gum style --bold --foreground 212 "Fetching available NixOS configurations..."
      flake_url="github:dominicegginton/dotfiles"

      # Evaluate and extract nixosConfigurations, excluding the installer
      configs=$(${pkgs.nix}/bin/nix eval "$flake_url#nixosConfigurations" --apply 'configs: builtins.concatStringsSep "\n" (builtins.filter (name: name != "residence-installer") (builtins.attrNames configs))' --raw)

      # Select configuration
      ${pkgs.gum}/bin/gum style --bold --foreground 212 "Select NixOS configuration to install:"
      configuration=$(echo "$configs" | ${pkgs.gum}/bin/gum choose --header="Available configurations:")

      if [ -z "$configuration" ]; then
        ${pkgs.gum}/bin/gum style --bold --foreground 196 "✗ No configuration selected. Aborting."
        exit 1
      fi

      # Get disko device names from the selected configuration
      ${pkgs.gum}/bin/gum style --bold --foreground 212 "Evaluating disko configuration..."
      configurationName="$flake_url#$configuration"
      disko_devices=$(${pkgs.nix}/bin/nix eval "$configurationName.config.disko.devices.disk" --apply 'disks: builtins.concatStringsSep "\n" (builtins.attrNames disks)' --raw 2>/dev/null || echo "")

      if [ -z "$disko_devices" ]; then
        ${pkgs.gum}/bin/gum style --bold --foreground 196 "✗ No disko devices found in configuration. Aborting."
        exit 1
      fi

      ## TODO: finish multi-disk support
      disk_flags=""

      # Install NixOS
      exec ${pkgs.disko}/bin/disko-install --write-efi-boot-entries --flake "$configurationName" $disk_flags
    '')
  ];

  display.gnome.enable = true;
}
