{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.modules.desktop;
in {
  imports = [./sway.nix];

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
    # Enable the desktop environment of choice.
    modules.sway.enable = mkIf (cfg.environment == "sway") true;

    # Enable the mpris proxy service for media player control
    # only available on linux systems for now (dbus).
    services.mpris-proxy.enable = mkIf isLinux true;

    # Enable home manager font configuration.
    fonts.fontconfig.enable = true;

    # Set the global x resrouces theme properties for applications
    # that use the xresources theme (alacritty, firefox, etc).
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

    # Alacritty terminal emulator configuration.
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          dynamic_padding = false;
          padding = {
            x = 0;
            y = 0;
          };
          decoration_theme_variant = "Dark";
        };
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        font = let
          family = "JetBrains Mono";
        in {
          normal = {
            inherit family;
            style = "Regular";
          };
          bold = {
            inherit family;
            style = "Bold";
          };
          italic = {
            inherit family;
            style = "Italic";
          };
          bold_italic = {
            inherit family;
            style = "Bold Italic";
          };
          size = 11;
        };
        selection = {save_to_clipboard = true;};
      };
    };

    # Firefox configuration.
    # Uses the firefox developer edition package.
    programs.firefox = mkIf cfg.firefox {
      enable = true;
      package = pkgs.firefox-devedition;
    };

    programs.vscode = mkIf cfg.vscode {
      enable = true;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      package = pkgs.vscode;
      extensions = with pkgs; [
        vscode-extensions.vscodevim.vim
        vscode-extensions.github.github-vscode-theme
        vscode-extensions.github.copilot
        vscode-extensions.yzhang.markdown-all-in-one
      ];
    };

    # Default packages to be installed across all desktop environments.
    # Includes the packages specified in the module configuration.
    home.packages = with pkgs;
      [
        # Font packages
        noto-fonts # Google noto-fonts
        noto-fonts-cjk # Google noto-fonts-cjk
        noto-fonts-emoji # Google noto-fonts-emoji
        font-awesome # Font awesome
        jetbrains-mono # JetBrains Mono fontface
        # Media packages
        mpv # Media player
      ]
      ++ cfg.packages;
  };
}
