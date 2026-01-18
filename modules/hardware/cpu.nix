{ config, lib, ... }:

{
  hardware.cpu = {
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
