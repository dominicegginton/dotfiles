{ inputs, config, lib, hostname, tailnet, ... }:

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
  services.unifi.enable = true;
  services.home-assistant.enable = true;
  topology.self = {
    hardware.info = "MSI Ghost GS60";
    interfaces.eth0 = {
      network = "burbage";
      type = "ethernet";
      physicalConnections = [ (config.lib.topology.mkConnection "quardon-switch-secondary" "eth2") ];
    };
  };

  # testing silverbullet
  services.silverbullet = {
    enable = true;
    listenAddress = hostname;
    listenPort = 8765;
    openFirewall = true;
  };

  # testing frigate
  secrets.cam = "7491f2bd-a2f1-43f3-9f53-b30e008631e3";
  services.frigate = {
    enable = true;
    hostname = "${hostname}.${tailnet}";
    settings = {
      auth.enabled = false;
      motion.enabled = true;
      record.enabled = true;
      snapshots.enabled = true;
      detect = {
        enabled = true;
        fps = 5;
      };
      cameras = {
        "01" = {
          ffmpeg.inputs = [
            { path = "rtsp://frigate:frigate@192.168.1.44/Preview_01_main"; roles = [ "record" ]; }
            { path = "rtsp://frigate:frigate@192.168.1.44/Preview_01_sub"; roles = [ "detect" ]; }
          ];
          webui_url = "http://192.168.1.44";
        };
        "02" = {
          ffmpeg.inputs = [
            { path = "rtsp://frigate:frigate@192.168.1.44/preview_02_main"; roles = [ "record" ]; }
            { path = "rtsp://frigate:frigate@192.168.1.44/Preview_02_sub"; roles = [ "detect" ]; }
          ];
          webui_url = "http://192.168.1.44";
        };
        "03" = {
          ffmpeg.inputs = [
            { path = "rtsp://frigate:frigate123@192.168.1.186:554/Preview_01_main"; roles = [ "record" ]; }
            { path = "rtsp://frigate:frigate123@192.168.1.186:554/Preview_01_sub"; roles = [ "detect" ]; }
          ];
          webui_url = "http://192.168.1.186";
        };
      };
    };
  };
}
