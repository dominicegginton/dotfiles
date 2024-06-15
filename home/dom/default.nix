{ config
, lib
, pkgs
, username
, desktop
, stateVersion
, ...
}:

let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in

{
  imports = [ ./sources ];

  modules.system.stateVersion = stateVersion;
  modules.system.username = username;

  modules.desktop = {
    enable = true;
    sway.enable = true;
    applications = {
      firefox.enable = true;

      alacritty = {
        enable = true;
        settings = {
          window.dynamic_padding = false;
          window.padding = {
            x = 0;
            y = 0;
          };
          scrolling.history = 10000;
          scrolling.multiplier = 3;
          selection.save_to_clipboard = true;
          font =
            let
              style = style: {
                family = "JetBrains Mono";
                style = style;
              };
            in
            {
              normal = style "Regular";
              bold = style "Bold";
              italic = style "Italic";
              bold_italic = style "Bold Italic";
              size = 11;
            };
        };
      };

      vscode = {
        enable = true;
        extensions = with pkgs.unstable.vscode-extensions; [
          github.github-vscode-theme
          github.copilot
          github.vscode-github-actions
          github.vscode-pull-request-github
          github.codespaces
          bierner.markdown-mermaid
          bierner.markdown-emoji
          bierner.markdown-checkbox
          bierner.emojisense
          bierner.docs-view
        ];
        userSettings = {
          "workbench.colorTheme" = "GitHub Dark Default";
          "workbench.startupEditor" = "none";
          "workbench.sideBar.location" = "right";
          "editor.minimap.enabled" = false;
        };
      };
    };
  };

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
