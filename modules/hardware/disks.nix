{ config, lib, ... }:

{
  options.hardware.disks.root.id = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "The disk identifier where the root filesystem will be created.";
  };

  config.disko.devices.disk.main = lib.mkIf (config.hardware.disks.root.id != "") {
    type = "disk";
    device = config.hardware.disks.root.id;
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
}

