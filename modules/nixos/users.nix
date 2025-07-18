{ lib, dlib, pkgs, ... }:

with lib;

{
  config = {
    secrets.dom = "be2b6a7a-7811-4711-86f0-b24200a41bbd";
    users.users = {
      dom = {
        description = dlib.maintainers.dominicegginton.name;
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
          "davfs2"
        ];
      };

      root = {
        description = "System administrator";
        isNormalUser = mkDefault false;
        isSystemUser = mkDefault true;
        hashedPassword = mkDefault null;
      };
    };

    home-manager.users.dom = _: {
      imports = [ ../../home/dom ];
      programs.home-manager.enable = true;
    };
  };
}
