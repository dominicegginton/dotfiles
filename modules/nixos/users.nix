{ lib, pkgs, ... }:

with lib;

{
  config = {
    modules.secrets.dom = "be2b6a7a-7811-4711-86f0-b24200a41bbd";
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

    home-manager.users.dom = _: {
      imports = [ ../../home/dom ];
      programs.home-manager.enable = true;
    };
  };
}
