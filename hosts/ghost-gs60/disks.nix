_: {
  fileSystems."/".device = "/dev/disk/by-uuid/c0a9248d-dff0-427e-8e87-cbb04c5de1fd";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-uuid/714A-640B";
  fileSystems."/boot".fsType = "vfat";
  swapDevices = [{device = "/dev/disk/by-uuid/8edf9107-5ea5-427a-803a-c34731886c52";}];
}
