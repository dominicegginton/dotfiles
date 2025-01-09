{ inputs, modulesPath, pkgs, lib, ... }:

with lib;

{
  imports = [ inputs.nixos-images.nixosModules.image-installer ];
  environment.systemPackages = with pkgs; [
    bottom
    host-status
    secrets-sync
  ];
}
