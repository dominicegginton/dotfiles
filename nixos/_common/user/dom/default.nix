{ config, desktop, lib, pkgs, ... }:

let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in

{
  imports = [ ]
    ++ lib.optionals (desktop != null) [
  ];

  environment.systemPackages = with pkgs; [ ] ++ lib.optionals (desktop != null) [ ];

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

    hashedPassword = "$6$7/G25Y0gpFNSL8e.$bovnvMyQ5b7c0KIxPsjTC5WiNrbH2HorNYGySEvNbVK6xxBiE/tAoW3u180.PV6IEgLVsUcFxYyJoT2oglMkS.";
    homeMode = "0755";
    isNormalUser = true;
    packages = [ pkgs.home-manager ];
    shell = pkgs.zsh;
  };
}
