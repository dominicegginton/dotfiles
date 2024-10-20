{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.virtualisation;
in

with lib;

{
  options.modules.services.virtualisation.enable = mkEnableOption "virtualisation";

  config = mkIf cfg.enable {
    virtualisation = {
      docker.enable = true;
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
