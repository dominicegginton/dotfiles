{ hostname, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.srvos.nixosModules.server
    ./disks.nix
    ./boot.nix
  ];

  modules = {
    services.networking.enable = true;
    services.networking.hostname = "burbage";
    services.virtualisation.enable = true;
    services.syncthing.enable = true;
    services.steam.enable = true;
    users.dom.enable = true;
    display.enable = true;
    display.plasma.enable = true;
  };
}
