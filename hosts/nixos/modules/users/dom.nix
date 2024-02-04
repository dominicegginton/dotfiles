{
  config,
  desktop,
  lib,
  pkgs,
  ...
}: let
  ifGroupsExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  sops.secrets."dom.password".neededForUsers = true;

  users.users.dom = {
    description = "Dominic Egginton";
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
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
