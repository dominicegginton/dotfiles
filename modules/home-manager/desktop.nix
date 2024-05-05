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

  options.modules.desktop.enable = mkEnableOption "desktop";
  options.modules.desktop.firefox = mkEnableOption "firefox";
  options.modules.desktop.vscode = mkEnableOption "vscode";
  options.modules.desktop.environment = mkOption rec {
    type = types.str;
    default = "sway";
    description = "Environment configuration";
  };
  options.modules.desktop.packages = mkOption rec {
    type = types.listOf types.package;
    default = [];
    description = "Packages to be installed";
  };

  config = mkIf cfg.enable {
    modules.sway.enable = mkIf (cfg.environment == "sway") true;
    services.mpris-proxy.enable = mkIf isLinux true;
    fonts.fontconfig.enable = true;
    xresources.properties = rec {
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

    programs.alacritty = rec {
      enable = true;
      settings = rec {
        window.dynamic_padding = false;
        window.padding = rec {
          x = 0;
          y = 0;
        };
        window.decoration_theme_variant = "Dark";
        scrolling.history = 10000;
        scrolling.multiplier = 3;
        selection.save_to_clipboard = true;
        font = let
          family = "JetBrains Mono";
        in rec {
          normal = rec {
            inherit family;
            style = "Regular";
          };
          bold = rec {
            inherit family;
            style = "Bold";
          };
          italic = rec {
            inherit family;
            style = "Italic";
          };
          bold_italic = rec {
            inherit family;
            style = "Bold Italic";
          };
          size = 11;
        };
      };
    };

    programs.firefox = mkIf cfg.firefox {
      enable = true;
      package = pkgs.firefox-devedition-bin;
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
