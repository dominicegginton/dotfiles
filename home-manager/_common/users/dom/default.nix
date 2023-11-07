{
  config,
  lib,
  hostname,
  pkgs,
  username,
  ...
}: let
  inherit (pkgs) stdenv;
  inherit (lib) mkIf;
in {
  imports = [
    ./console
    ./sources
  ];

  home = {
    file.".face".source = ./face.jpg;
    file.".ssh/config".text = "";

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  systemd.user.tmpfiles.rules = mkIf stdenv.isLinux [
    "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];
}
