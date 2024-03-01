{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.users;

  ifGroupsExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  options.modules.users = {
    users = mkOption {
      type = types.listOf types.str;
      description = "List of users for the system";
    };
  };

  config = {
    sops.secrets."dom.password".neededForUsers = true;

    users = {
      users.dom = mkIf (cfg.users != [] && builtins.elem "dom" cfg.users) {
        description = "Dominic Egginton";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."dom.password".path;
        extraGroups =
          [
            "audio"
            "input"
            "users"
            "video"
            "wheel"
          ]
          ++ ifGroupsExists [
            "docker"
            "podman"
          ];
        homeMode = "0755";
        shell = pkgs.zsh;
      };

      users.nixos = mkIf (cfg.users != [] && builtins.elem "nixos" cfg.users) {
        description = "NixOS";
        isNormalUser = true;
        home = "/var/empty";
        createHome = false;
      };

      users.root = {
        description = "System administrator";
        isNormalUser = false;
        hashedPassword = null;
      };
    };
  };
}
