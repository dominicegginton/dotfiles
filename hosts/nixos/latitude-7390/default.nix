# TODO: tidy this file:

{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.dell-latitude-7390
    ./disks.nix
    ./boot.nix
  ];

  hardware.mwProCapture.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  modules = {
    users.dom.enable = true;
    display.enable = true;
    display.plasma.enable = true;
    services = {
      distributedBuilds.enable = true;
      virtualisation.enable = true;
      bluetooth.enable = true;
      syncthing.enable = true;
      ssh.enable = true;
      networking = {
        enable = true;
        hostname = "latitude-7390";
        wireless = true;
      };
    };
  };
}
