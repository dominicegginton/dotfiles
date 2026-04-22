{ lib, ... }:

{
  config.virtualisation.vmVariant = {
    users.groups.nixosvmtest = lib.mkDefault { };

    users.users.nix = {
      description = lib.mkDefault "NixOS VM Test User";
      isNormalUser = lib.mkDefault true;
      initialPassword = lib.mkDefault "";
      group = lib.mkDefault "nixosvmtest";
    };
  };
}
