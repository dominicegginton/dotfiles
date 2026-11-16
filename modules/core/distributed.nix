{ config, lib, pkgs, tailnet, ... }:

{
  services.tailscale.enable = lib.mkDefault true;

  networking.firewall = {
    allowedTCPPorts = [ 5640 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  networking.hosts = {
    "100.64.0.10" = [ "latitude-7390.${tailnet}" ];
    "100.64.0.11" = [ "ghost-gs60.${tailnet}" ];
  };

  systemd.tmpfiles.rules = [
    "d /run/namespaces 0755 root root -"
    "d /srv/plan9 0755 root root root -"
  ];
}
