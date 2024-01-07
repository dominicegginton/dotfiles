{
  config,
  desktop,
  lib,
  pkgs,
  ...
}: let
  ifGroupsExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.dom = {
    description = "Dominic Egginton";
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
