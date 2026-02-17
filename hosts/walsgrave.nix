{
  self,
  lib,
  platform,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ ];

  hardware.disks.device = "/dev/sda";
  hardware.disks.swapSize = "16G";

  topology.self.hardware.info = "Server";
}
