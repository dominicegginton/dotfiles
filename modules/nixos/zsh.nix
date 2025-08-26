_:

{
  config.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    promptInit = "autoload -U promptinit && promptinit";
  };
}
