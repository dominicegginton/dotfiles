{ config, lib, ... }:

{
  options.hardware.disks = {
    root.id = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The disk identifier where the root filesystem will be created.";
    };

    ## extra options for more than just the root disk
    extra = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra disk identifiers for additional disks to be managed by disko.";
    };
  };

  config.disko.devices.disk = {
    main = lib.mkIf (config.hardware.disks.root.id != "") {
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
  // lib.mapAttrs (name: id: {
    type = "disk";
    device = id;
    content = {
      type = "gpt";
      partitions = {
        data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            mountpoint = "/mnt/${name}";
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  }) config.hardware.disks.extra;
}
