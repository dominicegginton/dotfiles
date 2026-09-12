{ config, lib, ... }:

{
  # Enable microcode updates for CPU stability and security
  hardware.cpu = {
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Enable redistributable firmware for hardware support
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Enable zram compressed swap to prevent OOM freezes while keeping swap in volatile memory
  zramSwap = {
    enable = lib.mkDefault true;
    memoryPercent = lib.mkDefault 50;
    algorithm = lib.mkDefault "zstd";
  };
}
