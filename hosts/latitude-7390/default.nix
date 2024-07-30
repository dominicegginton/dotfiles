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
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "ghost-gs60";
    system = "x86_64-linux";
    protocol = "ssh-ng";
    maxJobs = 1;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
  }];

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
