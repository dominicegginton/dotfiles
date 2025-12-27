{ self, lib, config, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  imports = with self.inputs.nixos-hardware.nixosModules; [ common-pc-laptop common-pc-laptop-ssd dell-latitude-7390 ];

  fileSystems."/".device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-uuid/8543-16DB";
  fileSystems."/boot".fsType = "vfat";
  swapDevices = [{ device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2"; }];

  hardware = {
    # TODO: swap to btrfs 
    # disks.root.id = "/dev/sda";

    bluetooth.enable = true;
    intel-gpu-tools.enable = true;
    logitech = {
      wireless = {
        enable = true;
        enableGraphical = true;
      };
    };
  };

  boot = {
    kernelModules = [ "kvm-intel" "vhost_vsock" "i2c-dev" "ddcci_backlight" ];
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  };

  display.gnome.enable = true;

  services = {
    logind.settings.Login.HandleLidSwitchDocked = "suspend";
    upower.enable = true;
    tlp = {
      enable = true;
      batteryThreshold.enable = true;
    };
  };

  programs = {
    vscode.enable = true;
    firefox.enable = true;
  };

  virtualisation.docker.enable = true;

  topology.self.hardware.info = "Dell Latitude 7390 2-in-1";
}
