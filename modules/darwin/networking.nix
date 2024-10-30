{ config, pkgs, ... }:

{
  config = {
    services.tailscale.enable = true;
    environment.systemPackages = [ pkgs.tailscale ];
  };
}
