{ config, lib, pkgs, ... }:

{
  config.virtualisation.vmVariant = {
    users.groups.nixosvmtest = { };
    users.users.nix = {
      description = "NixOS VM Test User";
      isNormalUser = true;
      initialPassword = "";
      group = "nixosvmtest";
    };
  };
}
