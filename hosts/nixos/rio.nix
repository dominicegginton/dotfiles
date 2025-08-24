{ inputs, lib, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [ common-pc-laptop common-pc-laptop-ssd ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  roles = [ "kiosk" ];
  extraUsers = [ "matt" ];
  filesystem.type = "btrfs";
  networking.wireless.enable = true;
  topology.self.hardware.info = "";
}
