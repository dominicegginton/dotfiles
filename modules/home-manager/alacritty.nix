{ config, ... }:

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
        font = {
          normal = {
            family = "monospace";
            style = "Regular";
          };
          bold = {
            family = "monospace";
            style = "Bold";
          };
          italic = {
            family = "monospace";
            style = "Italic";
          };
          bold_italic = {
            family = "monospace";
            style = "Italic";
          };
          size = 11;
        };
        colors = with config.scheme.withHashtag; rec {
          primary = { background = base00; foreground = base07; };
          cursor = { text = base02; cursor = base07; };
          normal = {
            inherit red green yellow blue cyan magenta;
            black = base00;
            white = base07;
          };
          bright = normal;
          dim = normal;
        };
      };
    };
  };
}
