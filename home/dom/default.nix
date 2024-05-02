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
  modules.desktop.packages = with pkgs; [
    thunderbird
    unstable.teams-for-linux
    unstable.chromium
    unstable.whatsapp-for-linux
    unstable.telegram-desktop
  ];

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
