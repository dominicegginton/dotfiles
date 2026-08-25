{
  config,
  lib,
  ...
}:

{
  options.impermanence.enable = lib.mkEnableOption "impermanence with ephemeral Btrfs root filesystem";

  config = lib.mkIf config.impermanence.enable {
    programs.fuse.userAllowOther = true;
    boot.initrd.supportedFilesystems = [ "btrfs" ];
    boot.initrd.kernelModules = [ "btrfs" ];
    fileSystems."/persist".neededForBoot = true;

    # Rollback root filesystem to a blank state on every boot
    boot.initrd.postDeviceCommands = lib.mkAfter /* bash */ ''
      MNT_DEV=""
      if [[ -e /dev/root_vg/root ]]; then
          MNT_DEV="/dev/root_vg/root"
      elif [[ -e /dev/disk/by-partlabel/disk-main-root ]]; then
          MNT_DEV="/dev/disk/by-partlabel/disk-main-root"
      elif [[ -e /dev/disk/by-label/root ]]; then
          MNT_DEV="/dev/disk/by-label/root"
      fi

      if [[ -n "$MNT_DEV" ]]; then
          mkdir -p /btrfs_tmp
          mount -o subvolid=5 "$MNT_DEV" /btrfs_tmp
          if [[ -e /btrfs_tmp/root ]]; then
              rm -rf /btrfs_tmp/root/home/*/.cache
              mkdir -p /btrfs_tmp/old_roots
              timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
              mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                  delete_subvolume_recursively "/btrfs_tmp/$i"
              done
              btrfs subvolume delete "$1"
          }

          # Cleanup old root subvolumes older than 14 days
          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +14 2>/dev/null); do
              delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
      fi
    '';

    # Persistent files and directories across reboots
    environment.persistence."/persist" = {
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/etc/ssl"
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
        "/var/lib/bluetooth"
        "/var/lib/iwd"
        "/var/lib/AccountsService"
        "/var/lib/flatpak"
        "/var/lib/boltd"
        "/var/lib/decky-loader"
        "/var/lib/systemd"
        "/root"
        "/home/dom"
        "/var/lib/onlyoffice/documentserver/App_Data"
        "/var/lib/oauth2-proxy"
      ];
      users.dom.directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "dev"
        "homebrew"
        ".gnupg"
        ".ssh"
        ".steam"
        ".local/share/Steam"
        ".local/share/decky-loader"
        ".var/app/com.valvesoftware.Steam"
        ".config/Yubico"
      ];
    };
  };
}
