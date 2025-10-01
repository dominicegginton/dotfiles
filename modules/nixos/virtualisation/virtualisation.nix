{ config, lib, pkgs, ... }:

{
  config = {
    virtualisation = {
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
    topology.self.interfaces.docker0 = lib.mkIf config.virtualisation.docker.enable {
      type = "bridge";
      virtual = true;
      addresses = [ "localhost" "127.0.0.1" ];
    };
  };
}
