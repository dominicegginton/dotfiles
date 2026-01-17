{ self, lib, config, platform, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ common-pc-laptop common-pc-laptop-ssd dell-latitude-7390 ];

  fileSystems."/" = { device = "/dev/disk/by-uuid/591e8f6a-01bb-4a7b-8f9d-546400359853"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/5D74-0ED5"; fsType = "vfat"; options = [ "fmask=0077" "dmask=0077" ]; };

  hardware = {
    bluetooth.enable = true;
    intel-gpu-tools.enable = true;
  };

  boot = {
    kernelModules = [ "kvm-intel" "vhost_vsock" "i2c-dev" "ddcci_backlight" ];
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  };

  display.gnome.enable = true;

  services = {
    lldap.enable = true; # move to a server - testing only
    silverbullet.enable = true; # move to a server - testing only
    logind.settings.Login.HandleLidSwitchDocked = "suspend";
    upower.enable = true;
    tlp = {
      enable = true;
      batteryThreshold.enable = true;
    };

    flatpak.enable = true;
  };

  topology.self.hardware.info = "Workstation";
}
