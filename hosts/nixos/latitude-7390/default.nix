{ inputs, ... }:

{
  imports = [ inputs.nixos-hardware.nixosModules.dell-latitude-7390 ];
  fileSystems."/".device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-uuid/8543-16DB";
  fileSystems."/boot".fsType = "vfat";
  swapDevices = [{ device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2"; }];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "vhost_vsock" ];
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";
  topology.self.hardware.info = "Dell Latitude 7390";
  display.enable = true;
  audio.enable = true;
  bluetooth.enable = true;
  networking.wireless.enable = true;
  virtualisation.enable = true;
}
