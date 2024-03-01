{
  config,
  inputs,
  lib,
  pkgs,
  hostname,
  platform,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.dell-latitude-7390
    ./disks.nix
  ];

  modules.networking.enable = true;
  modules.networking.hostname = hostname;
  modules.networking.wireless = true;
  modules.bluetooth.enable = true;

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2";
    }
  ];

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.logind = {
    extraConfig = "HandlePowerKey=suspend";
    lidSwitch = "suspend";
  };

  hardware = {
    mwProCapture.enable = true;
  };

  services.thermald.enable = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "${platform}";
}
