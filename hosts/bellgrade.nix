{
  self,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault pkgs.stdenv.hostPlatform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ ];

  hardware = {
    disks.root.id = "/dev/sda";
  };

  services.cage = {
    enable = true;
    package = pkgs.cage;
    program = "${pkgs.youtube}/bin/youtube-via-google-chrome";
    extraArguments = [ "-f" ];
    user = "dom";
  };

  topology.self.hardware.info = "Theater";
}
