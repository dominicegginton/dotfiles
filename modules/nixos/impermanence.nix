{ config
, lib
, pkgs
, modulesPath
, ...
}:
{
  config = {
    programs.fuse.enable = true;
    users.users.dom.extraGroups = [ "fuse" ];
    boot.initrd = {
      # Ensure Btrfs support
      supportedFilesystems = [ "btrfs" ];

      # Include necessary kernel modules
      kernelModules = [ "btrfs" "dm-mod" "dm-crypt" ];

      # Add btrfs-progs to initrd (other utilities should already be available)
      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfs
      '';

      # MINIMAL TEST - Just check if the script runs at all
      postDeviceCommands = ''
        echo "=== IMPERMANENCE TEST STARTED ===" > /dev/kmsg
        echo "Script is running during boot" > /dev/kmsg
        echo "=== IMPERMANENCE TEST FINISHED ===" > /dev/kmsg
      '';

      systemd = {
        enable = true;

        services.rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = [ "initrd.target" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt

            # We first mount the BTRFS root to /mnt
            # so we can manipulate btrfs subvolumes.
            mount -o subvol=/ /dev/mapper/enc /mnt

            # While we're tempted to just delete /root and create
            # a new snapshot from /root-blank, /root is already
            # populated at this point with a number of subvolumes,
            # which makes `btrfs subvolume delete` fail.
            # So, we remove them first.
            #
            # /root contains subvolumes:
            # - /root/var/lib/portables
            # - /root/var/lib/machines

            btrfs subvolume list -o /mnt/root |
              cut -f9 -d' ' |
              while read subvolume; do
                echo "deleting /$subvolume subvolume..."
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "deleting /root subvolume..." &&
              btrfs subvolume delete /mnt/root
            echo "restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/root-blank /mnt/root

            # Once we're done rolling back to a blank snapshot,
            # we can unmount /mnt and continue on the boot process.
            umount /mnt
          '';
        };
      };
      environment.persistence."/persist" = {
        directories = [
          "/etc/nixos"
          "/var/lib/ssh" # Persist SSH host keys
          "/var/lib/machines" # Persist systemd-nspawn containers
          "/var/lib/portables" # Persist portable services
          "/var/log" # Persist system logs
        ];

        files = [ "/etc/hosts" ];

        users.dom = {
          directories = [ ".ssh" "Documents" "Downloads" "Pictures" "Videos" "Music" "Projects" "dev" ".config" ".cache" ];
        }
          };
      };
    }
