{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.modules.desktop;
in {
  imports = [
    ./sway.nix
    ./gamescope.nix
  ];

  options.modules.desktop = {
    enable = mkEnableOption "desktop";
    firefox = mkEnableOption "firefox";
    vscode = mkEnableOption "vscode";

    environment = mkOption {
      type = types.str;
      default = "sway";
      description = "Environment configuration";
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Packages to be installed";
    };
  };

  config = mkIf cfg.enable {
    modules.sway.enable = mkIf (cfg.environment == "sway") true;
    services.mpris-proxy.enable = mkIf isLinux true;
    fonts.fontconfig.enable = true;

    xresources.properties = {
      "*color0" = "#141417";
      "*color8" = "#434345";
      "*color1" = "#D62C2C";
      "*color9" = "#DE5656";
      "*color2" = "#42DD76";
      "*color10" = "#A1EEBB";
      "*color3" = "#FFB638";
      "*color11" = "#FFC560";
      "*color4" = "#28A9FF";
      "*color12" = "#94D4FF";
      "*color5" = "#E66DFF";
      "*color13" = "#F3B6FF";
      "*color6" = "#14E5D4";
      "*color14" = "#A1F5EE";
      "*color7" = "#c8c8c8";
      "*color15" = "#e9e9e9";
    };

    programs.alacritty = {
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
        font = let
          style = style: {
            family = "JetBrains Mono";
            style = style;
          };
        in {
          normal = style "Regular";
          bold = style "Bold";
          italic = style "Italic";
          bold_italic = style "Bold Italic";
          size = 11;
        };
      };
    };

    programs.firefox = mkIf cfg.firefox {
      enable = true;
      package = pkgs.firefox-devedition-bin;
    };

    programs.vscode = mkIf cfg.vscode {
      enable = true;
      package = pkgs.unstable.vscode;
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;
      extensions = with pkgs.unstable.vscode-extensions; [
        bbenoist.nix
        vscodevim.vim
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

    home.packages = with pkgs;
      [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        font-awesome
        jetbrains-mono
        mpv
      ]
      ++ cfg.packages;
  };
}
