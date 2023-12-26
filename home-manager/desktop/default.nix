{
  desktop,
  pkgs,
  lib,
  username,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in {
  imports =
    []
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

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
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    jetbrains-mono
    alacritty
    mpv
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
    "x-scheme-handler/mailto" = "firefox.desktop";
    "text/calendar" = "firefox.desktop";
    "x-scheme-handler/irc" = "firefox.desktop";
    "audio/mpeg" = "mpv.desktop";
    "audio/x-flac" = "mpv.desktop";
    "audio/x-vorbis+ogg" = "mpv.desktop";
    "audio/x-wav" = "mpv.desktop";
    "audio/x-ms-wma" = "mpv.desktop";
    "audio/x-musepack" = "mpv.desktop";
    "audio/x-opus+ogg" = "mpv.desktop";
    "audio/x-speex+ogg" = "mpv.desktop";
    "video/mp4" = "mpv.desktop";
    "video/mpeg" = "mpv.desktop";
    "video/ogg" = "mpv.desktop";
    "video/quicktime" = "mpv.desktop";
  };
}
