{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.users;
in {
  options.modules.users = {
    dom.enable = mkEnableOption "Dominic Egginton";
    nixos.enable = mkEnableOption "NixOS";
  };

  config = rec {
    sops.secrets."dom.password".neededForUsers = true;

    users.users = rec {
      dom = mkIf cfg.dom.enable rec {
        description = "Dominic Egginton";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."dom.password".path;
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "audio"
          "input"
          "users"
          "video"
          "docker"
        ];
      };

      nixos = mkIf cfg.nixos.enable rec {
        description = "NixOS";
        isNormalUser = mkDefault true;
        home = mkDefault "/var/empty";
        createHome = mkDefault false;
      };

      root = rec {
        description = "System administrator";
        isNormalUser = mkDefault false;
        hashedPassword = mkDefault null;
      };
    };
  };
}
