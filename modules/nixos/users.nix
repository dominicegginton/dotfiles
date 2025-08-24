{ config, lib, dlib, pkgs, ... }:

with lib;

let
  defaultExtraGroups = [ "input" "audio" "video" "users" ];
in

{
  options.extraUsers = lib.mkOption {
    type = lib.types.listOf (lib.types.enum [ "matt" ]);
    default = [ ];
    description = "List of extra users to create on the system.";
  };

  config = {
    secrets.dom = "be2b6a7a-7811-4711-86f0-b24200a41bbd";
    secrets.matt = lib.mkIf (elem "matt" config.extraUsers) "";

    users.users = {
      root = {
        description = "System administrator";
        isNormalUser = mkDefault false;
        isSystemUser = mkDefault true;
        hashedPassword = mkDefault null;
      };

      dom = {
        description = dlib.maintainers.dominicegginton.name;
        isNormalUser = true;
        hashedPasswordFile = "/run/bitwarden-secrets/dom";
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = defaultExtraGroups ++ [
          "wheel"
          "davfs2"
          (lib.optionalString (config.virtualisation.docker.enable) "docker")
          (lib.optionalString (config.programs.adb.enable) "adbusers")
          (lib.optionalString (config.programs.adb.enable) "kvm")
        ];
      };

      matt = lib.mkIf (elem "matt" config.extraUsers) {
        description = "Matt";
        isNormalUser = true;
        hashedPasswordFile = "/run/bitwarden-secrets/matt";
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = defaultExtraGroups;
      };
    };

    home-manager.users = {
      dom = _: {
        imports = [ ../../home/dom ];
        programs.home-manager.enable = true;
      };
      matt = lib.mkIf (elem "matt" config.extraUsers) (_: {
        imports = [ ../../home/matt ];
        programs.home-manager.enable = true;
      });
    };
  };
}
