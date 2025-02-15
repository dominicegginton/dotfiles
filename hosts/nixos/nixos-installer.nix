{ inputs, pkgs, lib, ... }:

with lib;

{
  imports = with inputs.nixos-images.nixosModules; [ image-installer ];
  environment.systemPackages = with pkgs; [ bottom host-status ];
  topology.self.hardware.info = "NixOS Installer";
  topology.self.interfaces.tailscale = {
    network = "tailscale";
    virtual = true;
  };
}
