{ hostname, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.srvos.nixosModules.server
  ];

  modules = {
    services.networking.enable = true;
    services.virtualisation.enable = true;
    services.steam.enable = true;
    users.dom.enable = true;
    display.enable = true;
    display.plasma.enable = true;
  };
}
