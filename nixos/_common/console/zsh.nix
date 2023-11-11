{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    promptInit = "autoload -U promptinit && promptinit";
  };
}
