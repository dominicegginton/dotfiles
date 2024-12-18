{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    home-manager.users = {
      dom = _: {
        imports = [
          ../../home/dom
        ];
      };
    };
    users.users = {
      dom = {
        description = "Dominic Egginton";
        isNormalUser = true;
        hashedPasswordFile = "/run/bitwarden-secrets/dom";
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "audio"
          "input"
          "users"
          "video"
          "docker"
          "kvm"
          "abdusers"
        ];
      };

      nixremote = {
        description = "Nix Remote";
        isNormalUser = mkDefault true;
        home = mkForce "/var/empty";
        extraGroups = [ "nixremote" ];
      };

      root = {
        description = "System administrator";
        isNormalUser = mkDefault false;
        hashedPassword = mkDefault null;
      };
    };
  };
}
