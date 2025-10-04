{ config, lib, dlib, pkgs, hostname, ... }:

with lib;

let
  defaultExtraGroups = [
    "input"
    "audio"
    "video"
    "users"
    "lp"
  ]
  ++ optionals (config.networking.networkmanager.enable) [ "networkmanager" ];
  previlegedExtraGroups = [ "wheel" ]
    ++ optionals (config.services.printing.enable) [ "lpadmin" ]
    ++ optionals (config.virtualisation.docker.enable) [ "docker" ]
    ++ optionals (config.services.davfs2.enable) [ "dav2fs" ]
    ++ optionals (config.programs.adb.enable) [ "adbusers" "kvm" ];
in

{
  config = mkIf (hostname != "residence-installer") {
    secrets.dom = mkIf config.users.users.dom.enable "be2b6a7a-7811-4711-86f0-b24200a41bbd";

    users = {
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
          extraGroups = defaultExtraGroups ++ previlegedExtraGroups;
          openssh.authorizedKeys.keys = dlib.maintainers.dominicegginton.sshKeys;
        };
      };
    };

    home-manager.users = {
      dom = mkIf config.users.users.dom.enable ../../home/dom;
    };

    systemd.tmpfiles.rules = [ "R! /home/celestial 1777 root root -" ];
  };
}
