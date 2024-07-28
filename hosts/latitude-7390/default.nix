# TODO: tidy this file:
#        default.nix
#        disks.nix
#        boot.nix
#        harkware.nix

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.dell-latitude-7390
    ./disks.nix
    ./boot.nix
  ];

  hardware.mwProCapture.enable = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  modules = {
    users.dom.enable = true;
    desktop.plasma.enable = true;

    services = {
      virtualisation.enable = true;
      bluetooth.enable = true;
      syncthing.enable = true;

      networking = {
        enable = true;
        hostname = "latitude-7390";
        wireless = true;
      };
    };
  };
}
