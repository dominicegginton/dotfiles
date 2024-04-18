{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      promptInit = "autoload -U promptinit && promptinit";
    };

    environment.sessionVariables = {
      FLAKE = "~/.dotfiles";
    };

    environment.systemPackages = with pkgs; [
      git
      fzf
      pinentry-mac
    ];
  };
}
