{ config, lib, ... }:

{
  options.filesystem = {
    type = lib.mkOption {
      type = lib.types.enum [ null "ext4" "btrfs" ];
      default = null;
      description = "Filesystem type for the root partition.";
    };
    swapsize = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Size of the swap partition to create, e.g. '8G' or '512M'.";
    };
  };

  config = lib.mkIf (config.filesystem.type != null) {
    disko.devices.disk.main = lib.mkIf (config.filesystem.type == "btrfs") {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "128M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}
