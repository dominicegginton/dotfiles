{
  config,
  lib,
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

  # Kernel & hardware support
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

  # Jovian-NixOS Steam Deck handheld integration
  jovian.devices.steamdeck.enable = true;

  # User 'dom' passwordless configuration
  users.users.dom = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "";
  };

  security.sudo.wheelNeedsPassword = false;
  security.run0.wheelNeedsPassword = false;
  security.pam.services.login.allowNullPassword = true;

  # Enable Nix Distributed Build client
  services.nix-builder.client.enable = true;

  topology.self.hardware.info = "Steam Deck Handheld Console";
}
