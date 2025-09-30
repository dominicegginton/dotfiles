{ config, lib, dlib, pkgs, hostname, ... }:

with lib;

let
  defaultExtraGroups = [ "input" "audio" "video" "users" "lp" ];
  previlegedExtraGroups = [ "wheel" ]
    ++ optionals (config.services.printing.enable) [ "lpadmin" ]
    ++ optionals (config.virtualisation.docker.enable) [ "docker" ]
    ++ optionals (config.services.davfs2.enable) [ "dav2fs" ]
    ++ optionals (config.programs.adb.enable) [ "adbusers" "kvm" ];
in

{
  config = mkIf (hostname != "residence-installer") {
    secrets.dom = mkIf config.users.users.dom.enable "be2b6a7a-7811-4711-86f0-b24200a41bbd";
    secrets.matt = mkIf config.users.users.matt.enable "";

    users.users.celestial.group = "celestial";
    users.groups.celestial = { };

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

        celestial = {
          enable = false;
          isNormalUser = mkDefault true;
          hashedPassword = mkDefault null;
          shell = pkgs.zsh;
          extraGroups = defaultExtraGroups ++ [ "celestial" ];
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

        matt = {
          enable = false;
          isNormalUser = mkDefault true;
          description = "Matt";
          hashedPasswordFile = "/run/bitwarden-secrets/matt";
          homeMode = "0755";
          shell = pkgs.zsh;
          extraGroups = defaultExtraGroups;
        };
      };
    };

    home-manager.users = {
      celestial = mkIf config.users.users.celestial.enable ../../home/celestial;
      dom = mkIf config.users.users.dom.enable ../../home/dom;
      matt = mkIf config.users.users.matt.enable ../../home/matt;
    };

    systemd.tmpfiles.rules = lib.mkIf config.users.users.celestial.enable [
      "d /home/celestial 0755 celestial celestial -"
      "R! /home/celestial 1777 root root -"
    ];
  };
}
