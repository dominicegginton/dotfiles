_:

{
  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;
      defaultKeymap = "viins";
      oh-my-zsh.enable = true;
      oh-my-zsh.theme = "eastwood";
    };
  };
}
