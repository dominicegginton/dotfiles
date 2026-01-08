{ self, lib, config, platform, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault pkgs.stdenv.hostPlatform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ ];

  hardware = {
    disks.root.id = "/dev/sda";
  };

  topology.self.hardware.info = "Theater";
}
