{ desktop, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nvme-cli
    smartmontools
  ];

  services.smartd.enable = true;
}
