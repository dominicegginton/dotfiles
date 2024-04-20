{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    console = {
      font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
      keyMap = "uk";
      packages = with pkgs; [tamzen];
    };

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
      pinentry
    ];
  };
}