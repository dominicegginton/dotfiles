{ inputs, config, lib, hostname, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [ common-pc-laptop common-pc-laptop-ssd ];
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
    };
  };
  networking.wireless.enable = true;
  services.unifi.enable = true;
  services.home-assistant.enable = true;
  services.silverbullet.enable = true;
  services.mosquitto.enable = true;
  secrets.cam = "7491f2bd-a2f1-43f3-9f53-b30e008631e3";
  services.frigate = {
    enable = true;
    settings.cameras."Front Door" = lib.ffmpegReolinkCamera {
      ip = "000.000.0.000";
      port = 554;
      username = "frigate";
      password = "frigate";
      streams = [
        { stream = "Preview_01_main"; roles = [ "record" ]; }
        { stream = "Preview_01_sub"; roles = [ "detect" ]; }
      ];
    };
  };
  topology.self.hardware.info = "";
}
