{ inputs, pkgs, lib, ... }:

with lib;

{
  imports = with inputs.nixos-images.nixosModules; [ image-installer ];
  environment.systemPackages = with pkgs; [ bottom host-status secrets-sync ];
}
