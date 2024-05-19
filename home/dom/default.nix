{
  config,
  lib,
  pkgs,
  username,
  desktop,
  stateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in {
  imports = [./sources];

  modules.system.stateVersion = stateVersion;
  modules.system.username = username;
  modules.desktop.enable = true;
  modules.desktop.firefox = true;
  modules.desktop.vscode = true;
  modules.desktop.environment = desktop;

  systemd.user.tmpfiles.rules = mkIf isLinux [
    "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];

  home.packages = with pkgs; [
    bitwarden-cli
    discord
    whatsapp-for-linux
    telegram-desktop
  ];
}
