{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8543-16DB";
    fsType = "vfat";
  };

  # disko.devices = {
  #   disk = {
  #     my-disk = {
  #       device = "/dev/sda";
  #       type = "disk";
  #       content = {
  #         type = "gpt";
  #         partitions = {
  #           ESP = {
  #             type = "EF00";
  #             size = "500M";
  #             content = {
  #               type = "filesystem";
  #               format = "vfat";
  #               mountpoint = "/boot";
  #             };
  #           };
  #           root = {
  #             size = "100%";
  #             content = {
  #               type = "filesystem";
  #               format = "ext4";
  #               mountpoint = "/";
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
