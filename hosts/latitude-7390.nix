{
  self,
  lib,
  config,
  platform,
  ...
}:

{
  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Hardware-specific modules
  imports = with self.inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    dell-latitude-7390
  ];

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/591e8f6a-01bb-4a7b-8f9d-546400359853";
    fsType = "ext4";
  };

  # Boot partition (EFI)
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5D74-0ED5";
    fsType = "vfat";
    options = [
      "fmask=0077" # Restrict file permissions
      "dmask=0077" # Restrict directory permissions
    ];
  };

  # Swap configuration
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Kernel modules for hardware support
  boot.kernelModules = [
    "kvm-intel" # Virtualization
    "vhost_vsock" # Virtio socket support
    "i2c-dev" # I2C device access
    "ddcci_backlight" # DDC/CI monitor control
  ];

  # Additional kernel drivers
  boot.extraModulePackages = [
    config.boot.kernelPackages.ddcci-driver # DDC/CI driver
  ];

  # Initrd modules for boot-time hardware access
  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0
    "ahci" # SATA
    "usb_storage" # USB storage
    "sd_mod" # SD card
    "nvme" # NVMe storage
  ];

  # Enable host-specific features
  hardware.bluetooth.enable = true;
  programs.vscode.enable = true;

  # Graphical desktop environments
  display.gnome.enable = true;

  users.sssd = {
    enable = true;
    clientId = "e69b15fb09f5e9c840949d9f2ef5095d";
    userMap = "dominic.egginton@gmail.com:dom";
  };

  topology.self.hardware.info = "Workstation";

  # Enable Beszel monitoring (Agent)
  services.beszel.agent.enable = true;
}
