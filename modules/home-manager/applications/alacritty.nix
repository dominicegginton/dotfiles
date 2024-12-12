{ config, lib, ... }:

with lib;

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
        colors = with config.scheme.withHashtag;
          let
            default = {
              black = base00;
              white = base07;
              inherit red green yellow blue cyan magenta;
            };
          in
          {
            primary = { background = base00; foreground = base07; };
            cursor = { text = base02; cursor = base07; };
            normal = default;
            bright = default;
            dim = default;
          };
      };
    };
  };
}
