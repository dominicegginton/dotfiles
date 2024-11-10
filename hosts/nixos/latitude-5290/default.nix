{ ... }:

{
  imports = [
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
    services.networking.enable = true;
    services.networking.hostname = "precision-5530";
    services.networking.wireless = true;
  };
}
