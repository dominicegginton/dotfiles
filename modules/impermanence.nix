{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.impermanence;

  rollbackScript = ''
    MNT_DEV=""
    for i in {1..50}; do
        if [[ -e /dev/root_vg/root ]]; then
            MNT_DEV="/dev/root_vg/root"
            break
        elif [[ -e /dev/disk/by-partlabel/disk-main-root ]]; then
            MNT_DEV="/dev/disk/by-partlabel/disk-main-root"
            break
        elif [[ -e /dev/disk/by-label/root ]]; then
            MNT_DEV="/dev/disk/by-label/root"
            break
        fi
        ${pkgs.coreutils}/bin/sleep 0.1
    done

    if [[ -n "$MNT_DEV" ]]; then
        ${pkgs.coreutils}/bin/mkdir -p /btrfs_tmp
        ${pkgs.util-linux}/bin/mount -o subvolid=5 "$MNT_DEV" /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            ${pkgs.coreutils}/bin/mkdir -p /btrfs_tmp/old_roots
            timestamp=$(${pkgs.coreutils}/bin/date --date="@$(${pkgs.coreutils}/bin/stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
            ${pkgs.coreutils}/bin/mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(${pkgs.btrfs-progs}/bin/btrfs subvolume list -o "$1" | ${pkgs.coreutils}/bin/cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$1"
        }

        # Cleanup old root subvolumes older than configured retention days
        for i in $(${pkgs.findutils}/bin/find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +${toString cfg.retainDays} 2>/dev/null); do
            delete_subvolume_recursively "$i"
        done

        ${pkgs.btrfs-progs}/bin/btrfs subvolume create /btrfs_tmp/root
        ${pkgs.util-linux}/bin/umount /btrfs_tmp
    fi
  '';
in

{
  options.impermanence = {
    enable = lib.mkEnableOption "impermanence with ephemeral Btrfs root filesystem";
    retainDays = lib.mkOption {
      type = lib.types.int;
      default = 14;
      description = "Number of days to retain old root subvolumes before automatic deletion.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fuse.userAllowOther = true;
    boot.initrd.supportedFilesystems = [ "btrfs" ];
    boot.initrd.kernelModules = [ "btrfs" ];
    fileSystems."/persist".neededForBoot = true;

    # Rollback root filesystem to a blank state on every boot
    # Support both scripted initrd and systemd initrd
    boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) (lib.mkAfter rollbackScript);

    boot.initrd.systemd.services.rollback = lib.mkIf config.boot.initrd.systemd.enable {
      description = "Rollback Btrfs root subvolume";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = rollbackScript;
    };

    # Persistent files and directories across reboots
    environment.persistence."/persist" = {
      hideMounts = true;
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
        "/var/lib/AccountsService"
        "/var/lib/boltd"
        "/var/lib/systemd"
        "/root"
      ];
      users.dom.directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "dev"
        "homebrew"
        ".ssh"
        ".local/share/keyrings"
      ];
    };
  };
}
