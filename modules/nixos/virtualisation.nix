{ config, lib, pkgs, ... }:

{
  config = {
    virtualisation = {
      docker = lib.mkIf config.virtualisation.docker.enable {
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
    environment.systemPackages = with pkgs; lib.mkIf config.virtualisation.docker.enable [ qemu docker ];
    topology.self.interfaces.docker0 = {
      type = "bridge";
      virtual = true;
      addresses = [ "localhost" "127.0.0.1" ];
    };
  };
}
