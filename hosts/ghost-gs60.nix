{
  self,
  config,
  lib,
  hostname,
  platform,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    common-pc-laptop-hdd
    msi-gs60
  ];

  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdb";
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
        device = "/dev/sda";
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
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Ignore events from the lid switch
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.upower.ignoreLid = true;

  # Enable Tailscale Identity Provider (IdP)
  services.tsidp.enable = true;

  # Enable Immich Photos/Video Management Services
  # services.immich.enable = true;

  # Enable Ollama Large Language Model (LLM) AI Services
  # services.ollama.enable = true;

  # Enable Open-WebUI Large Language Model (LLM) AI Web Interface
  # services.open-webui.enable = true;

  # Enable Directory Information Tree & LDAP Services
  # services.dit0.enable = true;

  # Enable Frigate NVR & OD Services
  services.frigate = {
    enable = true;
    settings = {
      cameras = {
        "Frontdoor".ffmpeg.inputs = [
          {
            path = "rtsp://frigate:frigate123@192.168.1.226:554/Preview_01_main";
            roles = [ "record" ];
          }
          {
            path = "rtsp://frigate:frigate123@192.168.1.226:554/Preview_01_sub";
            roles = [ "detect" ];
          }
        ];
      };
    };
  };

  # Enable SilverBullet Notes Services
  services.silverbullet.enable = true;

  # Topology Definition
  topology.self = {
    hardware.info = "MSI Ghost GS60";

    # Network Interface Configuration
    interfaces.eth0 = {
      network = "ribble";
      type = "ethernet";
      addresses = [ hostname ];
      physicalConnections = [ (config.lib.topology.mkConnection "switch" "eth3") ];
    };
  };
}
