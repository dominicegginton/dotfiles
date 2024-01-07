{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    promptInit = "autoload -U promptinit && promptinit";
  };
}
