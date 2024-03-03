{
  config,
  lib,
  pkgs,
  username,
  stateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in {
  imports = [./sources];

  modules.system.stateVersion = stateVersion;
  modules.system.username = username;

  home = {
    file.".face".source = ./face.jpg;
    file.".ssh/config".text = "";
  };

  systemd.user.tmpfiles.rules = mkIf isLinux [
    "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -" # Development directory
    "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -" # Playgrounds directory
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -" # Dotfiles directory
  ];

  home.packages = with pkgs; [
    bitwarden-cli # Bitwarden password manager
  ];
}
