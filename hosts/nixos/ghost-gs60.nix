{ inputs, config, lib, hostname, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    common-pc-laptop-hdd
    msi-gs60
  ];
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                mountpoint = "/";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
      extra = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                mountpoint = "/mnt/data";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
    };
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.wireless.enable = true;
  services.logind.lidSwitch = "ignore";
  services.upower.ignoreLid = true;
  services.unifi.enable = true;
  services.home-assistant.enable = true;
  services.home-assistant.customComponents = [];
  services.silverbullet.enable = true;
  services.mosquitto.enable = true;
  secrets.cam = "7491f2bd-a2f1-43f3-9f53-b30e008631e3";
  services.frigate = {
    enable = true;
    settings = {
      cameras = {
        "Frontdoor".ffmpeg.inputs = [
          { path = "rtsp://frigate:frigate123@192.168.1.200:554/Preview_01_main"; roles = [ "record" ]; }
          { path = "rtsp://frigate:frigate123@192.168.1.200:554/Preview_01_sub"; roles = [ "detect" ]; }
        ];
      };
    };
  };
  topology.self = {
    hardware.info = "MSI Ghost GS60";
    interfaces.eth0 = {
      network = "burbage";
      type = "ethernet";
      addresses = [ hostname ];
      physicalConnections = [ (config.lib.topology.mkConnection "ribble-switch" "eth3") ];
    };
  };
}
