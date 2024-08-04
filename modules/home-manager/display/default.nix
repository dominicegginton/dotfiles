{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;

  cfg = config.modules.display;
in

with lib;

{
  imports = [
    ./plasma.nix
    ./sway.nix
  ];

  options.modules.display.enable = mkEnableOption "Enable graphical desktop environment";

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    services.mpris-proxy.enable = mkIf isLinux true;
    # TODO: use color scheme
    xresources.properties = mkIf isLinux {
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
    xdg.enable = mkIf isLinux true;
    home.packages =
      with pkgs; [ ]
        ++ (if isLinux then [ ] else [ ])
        ++ (if isDarwin then [ ] else [ ]);
  };
}
