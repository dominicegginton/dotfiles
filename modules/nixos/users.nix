{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    sops.secrets."dom.password".neededForUsers = true;

    users.users = {
      dom = {
        description = "Dominic Egginton";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."dom.password".path;
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "audio"
          "input"
          "users"
          "video"
          "docker"
        ];
      };

      nixremote = {
        description = "Nix Remote";
        isNormalUser = mkDefault true;
        home = mkForce "/var/empty";
        extraGroups = [ "nixremote" ];
      };

      nixos = {
        description = "NixOS";
        isNormalUser = mkDefault true;
        home = mkForce "/var/empty";
      };

      root = {
        description = "System administrator";
        isNormalUser = mkDefault false;
        hashedPassword = mkDefault null;
      };
    };
  };
}
