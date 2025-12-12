{ self, config, lib, pkgs, hostname, ... }:

with lib;

{
  config = {
    secrets.dom = "be2b6a7a-7811-4711-86f0-b24200a41bbd";

    users.users.dom = {
      enable = lib.mkDefault true;
      isNormalUser = lib.mkDefault true;
      description = self.outputs.lib.maintainers.dominicegginton.name;
      hashedPasswordFile = "/run/bitwarden-secrets/dom";
      homeMode = "0755";
      extraGroups = [
        "users" # Standard users group
        "wheel" # For sudo access
        "input" # For keyboard/mouse
        "audio" # For sound
        "video" # For GPU access
      ];
      openssh = {
        authorizedPrincipals = [ "dom@localhost" "dom@${hostname}" self.outputs.lib.maintainers.dominicegginton.email ];
        authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;
      };
    };

    home-manager.users.dom = ../../home/dom;
  };
}
