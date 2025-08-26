{ config, lib, dlib, pkgs, hostname, ... }:

with lib;

let
  defaultExtraGroups = [ "input" "audio" "video" "users" "lp" ];
  previlegedExtraGroups = [ "wheel" ]
    ++ lib.optionals (config.services.printing.enable) [ "lpadmin" ]
    ++ lib.optionals (config.virtualisation.docker.enable) [ "docker" ]
    ++ lib.optionals (config.services.davfs2.enable) [ "dav2fs" ]
    ++ lib.optionals (config.programs.adb.enable) [ "adbusers" "kvm" ];
in

{
  config = lib.mkIf (hostname != "residence-installer") {
      secrets.dom = lib.mkIf config.users.users.dom.enable "be2b6a7a-7811-4711-86f0-b24200a41bbd";
      secrets.matt = lib.mkIf config.users.users.matt.enable "";

      users.users = {
        root = {
          description = "System administrator";
          isNormalUser = mkDefault false;
          isSystemUser = mkDefault true;
          hashedPassword = mkDefault null;
        };

        dom = {
          enable = lib.mkDefault true;
          isNormalUser = true;
          description = dlib.maintainers.dominicegginton.name;
          hashedPasswordFile = "/run/bitwarden-secrets/dom";
          homeMode = "0755";
          shell = pkgs.zsh;
          extraGroups = defaultExtraGroups ++ previlegedExtraGroups;
        };

        matt = {
          enable = false;
          isNormalUser = true;
          description = "Matt";
          hashedPasswordFile = "/run/bitwarden-secrets/matt";
          homeMode = "0755";
          shell = pkgs.zsh;
          extraGroups = defaultExtraGroups;
        };
      };

      home-manager.users = {
        dom = lib.mkIf config.users.users.dom.enable ../../home/dom;
        matt = lib.mkIf config.users.users.matt.enable ../../home/matt;
      };
    };
}
