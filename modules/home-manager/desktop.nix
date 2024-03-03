{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop;
in {
  imports = [./sway.nix];

  options.modules.desktop = {
    enable = mkEnableOption "desktop";
    firefox = mkEnableOption "firefox";
    media = mkEnableOption "media";

    environment = mkOption {
      type = types.str;
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

    fonts.fontconfig.enable = true;

    xdg.mimeApps.defaultApplications = mkIf cfg.firefox {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };

    home.packages = with pkgs;
      [
        noto-fonts # Google noto-fonts
        noto-fonts-cjk # Google noto-fonts-cjk
        noto-fonts-emoji # Google noto-fonts-emoji
        font-awesome # Font awesome
        jetbrains-mono # JetBrains Mono fontface
        alacritty # Alacritty terminal emulator
        mpv # Media player
      ]
      ++ cfg.packages;
  };
}
