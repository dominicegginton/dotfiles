{
  self,
  config,
  lib,
  pkgs,
  platform,
  ...
}:

{
  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Disko storage layout
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  # Kernel & hardware support (Semi-custom AMD Zen 4 6C/12T CPU & RDNA 3 GPU)
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  # Bootloader configuration
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = lib.mkDefault true;
    timeout = 3;
  };

  # Enable shared Jovian SteamOS configuration
  jovian.enable = true;

  topology.self.hardware.info = "Steam Machine Console";
}
