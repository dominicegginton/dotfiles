{ config, ... }:

{
  config = {
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.promptInit = "autoload -U promptinit && promptinit";
    environment.variables.EDITOR = "vim";
    environment.variables.SYSTEMD_EDITOR = "vim";
    environment.variables.VISUAL = "vim";
  };
}
