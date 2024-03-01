{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.console;
in {
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

    environment.systemPackages = with pkgs; [
      git
      pinentry
    ];
  };
}
