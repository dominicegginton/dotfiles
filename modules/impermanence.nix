{ config
, lib
, pkgs
, modulesPath
, ...
}:
{
  config = {
    boot.initrd = {
      supportedFilesystems = [ "btrfs" ]; # ensure btrfs is supported in initrd
      kernelModules = [ "btrfs" "dm-mod" "dm-crypt" ]; # load necessary kernel modules 
      systemd = {
        enable = true;
        services.impermanence-rollback = {
          description = "Disk rollback for impermanence";
          wantedBy = [ "initrd.target" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            echo "Performing impermanence rollback..."
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
