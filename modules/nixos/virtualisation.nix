{ config, lib, pkgs, ... }:

{
  options.virtualisation.enable = lib.mkEnableOption "virtualisation";

  config = lib.mkIf config.virtualisation.enable {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          flags = [ "--all" ];
          dates = "daily";
        };
      };
      vmVariant = {
        users.groups.nixosvmtest = { };
        users.users.nix = {
          description = "NixOS VM Test User";
          isNormalUser = true;
          initialPassword = "";
          group = "nixosvmtest";
        };
      };
    };

    environment.systemPackages = with pkgs; [ qemu docker ];
  };
}
