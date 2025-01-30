{ inputs, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [
    msi-gs60
    common-pc-laptop
    common-pc-laptop-ssd
    common-pc-laptop-hdd
    common-gpu-nvidia
    ./hardware-configuration.nix
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.mwProCapture.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  environment.sessionVariables."VK_DRIVER_FILES" = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  modules = {
    networking.wireless.enable = true;
    services.homepage-dashboard.enable = true;
    services.immich.enable = true;
    services.unifi.enable = true;
    services.home-assistant.enable = true;
  };
}
