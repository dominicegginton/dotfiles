{ config, lib, hostname, pkgs, username, ... }:

{
  imports = [
   ./console
   ./sources
  ];

  home = {
    file.".face".source = ./face.jpg;
    file.".ssh/config".text = "";

    packages = with pkgs; [ ];

    sessionVariables = { };
  };

  programs = { };

  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];
}
