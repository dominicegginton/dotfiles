{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = rec {
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.promptInit = "autoload -U promptinit && promptinit";
    environment.systemPackages = with pkgs; [
      git
      fzf
      pinentry-mac
    ];
  };
}
