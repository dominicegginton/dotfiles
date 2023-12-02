{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    autocd = true;
    defaultKeymap = "viins";
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "eastwood";
  };
}
