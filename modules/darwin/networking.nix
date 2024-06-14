{ config
, lib
, pkgs
, ...
}:

with lib;

{
  config = {
    services.tailscale.enable = true;
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
