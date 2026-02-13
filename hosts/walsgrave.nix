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

  topology.self.hardware.info = "Server";
}
