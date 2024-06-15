{ config
, lib
, pkgs
, ...
}:

let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.modules.desktop;
in

with lib;

{
  imports = [
    ./applications
    ./sway.nix
    ./gamescope.nix
  ];

  options.modules.desktop = {
    enable = mkEnableOption "Enable graphical desktop environment";
    background = mkOption {
      type = types.path;
      default = ./background.jpg;
      description = "Path to the background image";
    };
    defaultApplication = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Default applications for xdg";
    };
  };

  config = mkIf cfg.enable {
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
    xdg = {
      enable = true;
      mimeApps.defaultApplications = cfg.defaultApplications;
    };
    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      jetbrains-mono
      mpv
    ];
  };
}
