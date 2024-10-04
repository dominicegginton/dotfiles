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
    display.enable = true;
    display.plasma.enable = true;
    services.distributedBuilds.enable = true;
    services.virtualisation.enable = true;
    services.bluetooth.enable = true;
    services.syncthing.enable = true;
    services.ssh.enable = true;
    services.networking.enable = true;
    services.networking.hostname = "latitude-7390";
    services.networking.wireless = true;
  };
}
