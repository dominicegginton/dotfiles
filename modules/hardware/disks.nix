{
  self,
  config,
  lib,
  ...
}:

with lib;

{
  options.hardware.disks = {
    device = mkOption {
      description = "The disk used by disko.";
      type = types.nullOr self.inputs.disko.lib.optionTypes.absolute-pathname;
      default = null;
    };

    swapSize = mkOption {
      description = "The amount of swap allocated by disko.";
      type = types.nullOr types.str;
      default = null;
    };
  };

  config.disko.devices = lib.mkIf (config.hardware.disks.device != null) {
    disk.main = {
      device = config.hardware.disks.device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "root_vg";
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          ${if config.hardware.disks.swapSize == null then null else "swap"} = {
            size = config.hardware.disks.swapSize;
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/";
                };
                "/old_roots" = { };
                "/persist" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/persist";
                };
                "/nix" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
