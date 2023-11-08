{
  config,
  lib,
  hostname,
  pkgs,
  username,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in {
  home = {
    file.".face".source = ./face.jpg;
    file.".ssh/config".text = "";
  };

  systemd.user.tmpfiles.rules = mkIf isLinux [
    "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];
}
