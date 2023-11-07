{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8543-16DB";
    fsType = "vfat";
  };
}
