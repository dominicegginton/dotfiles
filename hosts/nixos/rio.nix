{ inputs, lib, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [ common-pc-laptop common-pc-laptop-ssd ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  display.gnome.enable = true;
  users.users.matt.enable = lib.mkDefault true;
  networking.wireless.enable = true;
  services.tlp.enable = true;
  topology.self.hardware.info = "";
}
