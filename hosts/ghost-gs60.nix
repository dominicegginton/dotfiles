{ self
, config
, lib
, pkgs
, hostname
, platform
, ...
}:

{
  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Explicitly disable impermanence on this machine
  impermanence.enable = false;

  # Hardware-specific modules
  imports = with self.inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    msi-gs60
  ];

  # Disko configuration for storage layout
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Btrfs root partition
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
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];

    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Systemd configuration to prevent system from sleeping/suspending
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Hardware services and application servers
  services = {
    # Ignore events from the lid switch to keep server online
    logind.settings.Login.HandleLidSwitch = "ignore";
    upower.ignoreLid = true;

    # Thermal daemon to regulate temperature on headless laptop server
    thermald.enable = true;

    # Headless NVIDIA GPU configuration for hardware media transcoding & compute
    xserver.videoDrivers = [ "nvidia" ];

    # Enable Tailscale Identity Provider (IdP)
    tsidp.enable = true;

    # Enable Immich Photos/Video Management Services with CUDA acceleration
    immich = {
      enable = true;
      accelerationDevices = [ "cuda" ];
    };

    # Enable Jellyfin Media Server Services
    jellyfin.enable = true;

    # Enable Transmission BitTorrent client
    transmission.enable = true;

    # Enable Frigate NVR & OD Services
    frigate = {
      enable = true;
      settings = {
        cameras = {
          "Frontdoor" = {
            ffmpeg = {
              inputs =
                let
                  cameraIp = builtins.head config.nodes.security-camera.interfaces.eth0.addresses;
                in
                [
                  {
                    path = "rtsp://frigate:frigate123@${cameraIp}:554/Preview_01_main";
                    roles = [ "record" ];
                  }
                  {
                    path = "rtsp://frigate:frigate123@${cameraIp}:554/Preview_01_sub";
                    roles = [ "detect" ];
                  }
                ];
            };
          };
        };
      };
    };

    # Enable SilverBullet Notes Services
    silverbullet.enable = true;

    # Enable Nix Distributed Build and Harmonia services (Machine Mesh)
    nix-builder.enable = true;
    harmonia-custom.enable = true;
  };

  # Hardware-accelerated graphics drivers for VA-API media transcoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false; # Disable X11 GUI settings app on headless server
    nvidiaPersistenced = true;
  };

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
