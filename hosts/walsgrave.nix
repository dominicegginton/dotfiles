{ self, lib, platform, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ common-pc-laptop ];

  hardware = {
    disks.root.id = "/dev/sda";
    bluetooth.enable = true;
    intel-gpu-tools.enable = true;
  };

  display.gnome.enable = true;

  services = {
    upower.enable = true;
    tlp = {
      enable = true;
      batteryThreshold.enable = true;
    };

    bitmagnet.enable = true;
    frigate.enable = true;
    jellyfin.enable = true;
    immich.enable = true;
    silverbullet.enable = true;
  };

  topology.self.hardware.info = "Home compute server";
}
