{ inputs, pkgs, lib, hostname, tailnet, ... }:

with lib;

{
  environment.systemPackages = with pkgs; [ tailscale bottom host-status ];
  networking = { hostName = hostname; };
  topology.self = {
    hardware.info = "ad-doc usb flash drive";
    interfaces.tailscale0 = {
      network = tailnet;
      type = "tailscale";
      icon = ../../assets/tailscale.svg;
      virtual = true;
    };
  };
}
