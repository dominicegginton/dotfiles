{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    console.keyMap = "uk";
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.promptInit = "autoload -U promptinit && promptinit";
    environment.systemPackages = with pkgs; [
      git
      fzf
      pinentry
    ];
  };
}
