{
  self,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault pkgs.stdenv.hostPlatform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ ];

  hardware.disks.device = "/dev/sda";
  hardware.disks.swapSize = "16G";

  services.cage = {
    enable = true;
    package = pkgs.cage;
    program = pkgs.lib.getExe pkgs.youtube-tv;
    extraArguments = [ "-f" ];
    user = "dom";
  };

  topology.self.hardware.info = "Theater";
}
