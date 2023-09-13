{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";

    plugins = with pkgs.tmuxPlugins; [
      sensible
    ];

    # allow RGB color values in tmux in alacritty
    extraConfig = ''set-option -a terminal-overrides ",alacritty:RGB"'';
  };
}
