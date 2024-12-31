{ pkgs, ... }:

{
  config = {
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.promptInit = "autoload -U promptinit && promptinit";
  };
}
