{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
