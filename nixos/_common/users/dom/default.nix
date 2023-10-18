{ config, desktop, lib, pkgs, ... }:

let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in

{
  imports = [ ]
    ++ lib.optionals (desktop != null) [ ];

  environment.systemPackages = with pkgs; [ ]
    ++ lib.optionals (desktop != null) [ ];

  users.users.dom = {
    description = "Dominic Egginton";
    extraGroups = [
      "audio"
      "input"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];

    homeMode = "0755";
    isNormalUser = true;
    packages = with pkgs; [ home-manager ];
    shell = pkgs.zsh;
  };
}
