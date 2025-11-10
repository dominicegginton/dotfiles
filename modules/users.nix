{ config, lib, dlib, pkgs, hostname, ... }:

with lib;

{
  config = mkIf (hostname != "residence-installer") {
    secrets.dom = mkIf config.users.users.dom.enable "be2b6a7a-7811-4711-86f0-b24200a41bbd";

    users = {
      defaultUserShell = pkgs.zsh;
      users = {
        root = {
          enable = mkDefault true;
          description = "System administrator";
          isNormalUser = mkDefault false;
          isSystemUser = mkDefault true;
          hashedPassword = mkDefault null;
          openssh = {
            authorizedPrincipals = [ "root@localhost" "root@${hostname}" dlib.maintainers.dominicegginton.email ];
            authorizedKeys.keys = dlib.maintainers.dominicegginton.sshKeys;
          };
        };

        dom = {
          enable = mkDefault true;
          isNormalUser = mkDefault true;
          description = dlib.maintainers.dominicegginton.name;
          hashedPasswordFile = "/run/bitwarden-secrets/dom";
          homeMode = "0755";
          shell = pkgs.zsh;
          extraGroups = [
            "users" # Standard users group
            "wheel" # For sudo access
            "input" # For keyboard/mouse
            "audio" # For sound
            "video" # For GPU access
          ];
          openssh = {
            authorizedPrincipals = [ "dom@localhost" "dom@${hostname}" dlib.maintainers.dominicegginton.email ];
            authorizedKeys.keys = dlib.maintainers.dominicegginton.sshKeys;
          };
        };
      };
    };

    # TODO: refactor to remove
    home-manager.users = {
      dom = mkIf config.users.users.dom.enable ../home/dom;
    };

    # TODO: test file in home directory
    users.home.dom.files."welcome.txt" = "Weclome to your Residence system, dom!";
  };
}
