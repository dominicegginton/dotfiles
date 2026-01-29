{
  self,
  lib,
  platform,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ ];

  hardware = {
    disks.root.id = "/dev/sda";
  };

  services = {
    bitmagnet.enable = true;
    frigate.enable = true;
    jellyfin.enable = true;
    immich.enable = true;
    silverbullet.enable = true;
  };

  topology.self.hardware.info = "Server";
}
