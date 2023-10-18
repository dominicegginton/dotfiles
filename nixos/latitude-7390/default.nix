{ config, inputs, lib, pkgs, platform, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../_common/services/wireless.nix
    (import ./disks.nix { })
  ];

  swapDevices = [{
    device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2";
  }];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    mwProCapture.enable = true;
  };

  services.thermald.enable = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "${platform}";
}
