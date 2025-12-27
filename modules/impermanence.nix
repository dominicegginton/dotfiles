{ config
, lib
, pkgs
, modulesPath
, ...
}:
{
  config = {
    boot.initrd = {
      supportedFilesystems = [ "btrfs" ];
      kernelModules = [ "btrfs" "dm-mod" "dm-crypt" ];
      systemd = {
        enable = true;
        services.impermanence-rollback = {
          description = "Disk rollback for impermanence";
          wantedBy = [ "initrd.target" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            echo "Rolling back BTRFS root subvolume to a pristine state..."

            mkdir -p /mnt
            mount -o subvol=/ /dev/mapper/enc /mnt

            btrfs subvolume list -o /mnt/root |
              cut -f9 -d' ' |
              while read subvolume; do
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              btrfs subvolume delete /mnt/root

            echo "Restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/root-blank /mnt/root
            umount /mnt          
          '';
        };
      };
    };

    environment.persistence = {
      "/persist" = {
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
          "/var/lib/bluetooth"
          "/var/lib/AccountsService"
          "/root"
          "/home/dom"
        ];
      };
    };
  };
}
