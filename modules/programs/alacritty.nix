{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.alacritty.enable = lib.mkEnableOption "Alacritty terminal emulator";

  config = lib.mkIf config.programs.alacritty.enable {
    environment = {
      systemPackages = [ pkgs.alacritty ];
      etc."alacritty.toml".text = ''
        window:
          dynamic_padding: false
          padding:
            x: 0
            y: 0
        scrolling:
          history: 10000
          multiplier: 3
        selection:
          save_to_clipboard: true
        font:
          normal:
            family: monospace
            style: Regular
          bold:
            family: monospace
            style: Bold
          italic:
            family: monospace
            style: Italic
          bold_italic:
            family: monospace
            style: Italic
          size: 11.0
        colors: ${
          with config.scheme.withHashtag;
          ''
            primary:
              background: "${base00}"
              foreground: "${base07}"
            cursor:
              text: "${base02}"
              cursor: "${base07}"
            normal:
              black:   "${base00}"
              red:     "${red}"
              green:   "${green}"
              yellow:  "${yellow}"
              blue:    "${blue}"
              magenta: "${magenta}"
              cyan:    "${cyan}"
              white:   "${base07}"
            bright:
              black:   "${base00}"
              red:     "${red}"
              green:   "${green}"
              yellow:  "${yellow}"
              blue:    "${blue}"
              magenta: "${magenta}"
              cyan:    "${cyan}"
              white:   "${base07}"
            dim:
              black:   "${base00}"
              red:     "${red}"
              green:   "${green}"
              yellow:  "${yellow}"
              blue:    "${blue}"
              magenta: "${magenta}"
              cyan:    "${cyan}"
              white:   "${base07}"
          ''
        };
      '';
    };
  };
}
