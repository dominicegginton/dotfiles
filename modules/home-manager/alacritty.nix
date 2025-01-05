{ config, lib, pkgs, ... }:

with lib;
with config.scheme.withHashtag;

let
  default = {
    inherit red green yellow blue cyan magenta;
    black = base00;
    white = base07;
  };
  lightTheme = {
    primary = { background = base00; foreground = base07; };
    cursor = { text = base02; cursor = base07; };
    normal = default;
    bright = default;
    dim = default;
  };
  darkTheme = {
    primary = { background = base00; foreground = base07; };
    cursor = { text = base02; cursor = base07; };
    normal = default;
    bright = default;
    dim = default;
  };
in

{
  config = {
    programs.alacritty = {
      enable = true;
      settings = {
        window.dynamic_padding = false;
        window.padding = { x = 0; y = 0; };
        scrolling.history = 10000;
        scrolling.multiplier = 3;
        selection.save_to_clipboard = true;
        font =
          let
            style = style: {
              family = "monospace";
              inherit style;
            };
          in
          {
            normal = style "Regular";
            bold = style "Bold";
            italic = style "Italic";
            bold_italic = style "Bold Italic";
            size = 11;
          };
        colors = lightTheme;
      };
    };

    home.file."alacritty-light-theme.toml".source = (pkgs.formats.toml { }).generate "alacritty-light-theme.toml" { colors = lightTheme; };
    home.file."alacritty-dark-theme.toml".source = (pkgs.formats.toml { }).generate "alacritty-dark-theme.toml" { colors = darkTheme; };
  };
}
