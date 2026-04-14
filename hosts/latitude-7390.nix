{
  self,
  lib,
  config,
  platform,
  ...
}:

{
  # Host Platform Definition
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Host Specific Modules
  imports = with self.inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    dell-latitude-7390
  ];

  # Host File System Definition
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/591e8f6a-01bb-4a7b-8f9d-546400359853";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5D74-0ED5";
    fsType = "vfat";
    options = [
      "fmask=0077" # Restrict file permissions
      "dmask=0077" # Restrict directory permissions
    ];
  };

  # Host Kernel Modules
  boot.kernelModules = [
    "kvm-intel" # Intel Virtualization
    "vhost_vsock" # Virtio Socket Support
    "i2c-dev" # I2C Device Support
    "ddcci_backlight" # DDC/CI Backlight Control
  ];

  # Host Extra Module Packages
  boot.extraModulePackages = [
    config.boot.kernelPackages.ddcci-driver # DDC/CI Driver
  ];

  # Host Initrd Kernel Modules
  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0 Support
    "ahci" # SATA Support
    "usb_storage" # USB Storage Support
    "sd_mod" # SD Card Support
    "nvme" # NVMe Support
  ];

  # Bluetooth Support
  hardware.bluetooth.enable = true;

  # Gnome Desktop Environment
  display.gnome.enable = true;

  services.immich.enable = true; # TODO: REMOVE
  services.tsidp.enable = true; # TODO: REMOVE

  # Topology Host Definition
  topology.self.hardware.info = "Workstation";
}
