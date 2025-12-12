{ lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];

  roles = [ "installer" ];
  image.baseName = lib.mkDefault "residence-installer";
  console.earlySetup = true;

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
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
      
      # Get available physical disks
      physical_disks=$(${pkgs.lsblk}/bin/lsblk -dn -o NAME,SIZE,TYPE | ${pkgs.gnugrep}/bin/grep 'disk')
      physical_disk_names=$(echo "$physical_disks" | ${pkgs.coreutils}/bin/awk '{print $1}')
      
      # Map each disko device to a physical disk
      disk_flags=""
      while IFS= read -r disko_device; do
        ${pkgs.gum}/bin/gum style --bold --foreground 212 "Select physical disk for disko device '$disko_device':"
        echo "$physical_disks"
        physical_disk=$(echo "$physical_disk_names" | ${pkgs.gum}/bin/gum choose --header="Select physical disk for '$disko_device':")
        
        if [ -z "$physical_disk" ]; then
          ${pkgs.gum}/bin/gum style --bold --foreground 196 "✗ No disk selected for '$disko_device'. Aborting."
          exit 1
        fi
        
        disk_flags="$disk_flags --disk $disko_device /dev/$physical_disk"
      done <<< "$disko_devices"

      # Confirm installation
      ${pkgs.gum}/bin/gum style --bold --foreground 214 "Configuration: $configuration"
      ${pkgs.gum}/bin/gum style --bold --foreground 214 "Disk mappings:$disk_flags"
      ${pkgs.gum}/bin/gum confirm "Install NixOS? This will erase all data on the selected disks." || exit 1

      # Install NixOS
      exec ${pkgs.disko}/bin/disko-install --write-efi-boot-entries --flake "$configurationName" $disk_flags
    '')
  ];
}
