{ config
, lib
, pkgs
, ...
}:

with lib;

{
  config = {
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.promptInit = "autoload -U promptinit && promptinit";
    environment.systemPackages = with pkgs; [
      git
      fzf
      pinentry_mac
    ];
  };
}
