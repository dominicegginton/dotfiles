{
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
  #   fsType = "ext4";
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/8543-16DB";
  #   fsType = "vfat";
  # };
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = "/dev/dis/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ89N41861140974L";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = ["defaults" "size=2G" "mode=755"];
      };
    };
  };
  fileSystems = {
    "/persist".neededForBoot = true;
  };
}
