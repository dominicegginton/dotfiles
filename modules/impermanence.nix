{
  lib,
  ...
}:

{
  config = {
    programs.fuse.userAllowOther = true;
    boot.initrd.supportedFilesystems = [ "btrfs" ];
    boot.initrd.kernelModules = [ "btrfs" ];
    fileSystems."/persist".neededForBoot = true;
    boot.initrd.postDeviceCommands = lib.mkAfter /* bash */ ''
      mkdir /btrfs_tmp
      mount /dev/root_vg/root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          rm -r /btrfs_tmp/root/home/*/.cache
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

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +14); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

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
        "/var/lib/iwd"
        "/var/lib/AccountsService"
        "/var/lib/flatpak"
        "/var/lib/boltd"
        "/root"
        "/home/dom"
      ];
      users.dom.directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "dev"
        ".gnupg"
        ".ssh"
      ];
    };
  };
}
