{ config, lib, dlib, pkgs, hostname, ... }:

with lib;

{
  config = {
    users = {
      defaultUserShell = pkgs.zsh;
      users = {
        root = {
          enable = lib.mkDefault true;
          description = "System administrator";
          isNormalUser = lib.mkDefault false;
          isSystemUser = lib.mkDefault true;
          hashedPassword = lib.mkDefault null;
          openssh = {
            authorizedPrincipals = [ "root@localhost" "root@${hostname}" dlib.maintainers.dominicegginton.email ];
            authorizedKeys.keys = dlib.maintainers.dominicegginton.sshKeys;
          };
        };
      };
    };
  };
}
