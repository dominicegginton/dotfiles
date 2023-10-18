{ config, lib, hostname, pkgs, username, ... }:

{
  imports = [ ];

  home = {
    file.".face".source = ./face.png;
    file.".ssh/config".text = "";
    file.".config".source = ./config;
    file.".config".recursive = true;
    file.".arup.gitconfig".srouce = ./sources/arup.gitconfig;
    file.".editorconfig".source = ./sources/editorconfig;
    file.".gitconfig".source = ./sources/gitconfig;
    file.".gitingore".source = ./sources/gitignore;
    file.".gitmessage".source = ./sources/gitmessage;
    file.".npmrc".source = ./sources/npmrc;
    file."background.png".source = ./sources/background.png;

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
