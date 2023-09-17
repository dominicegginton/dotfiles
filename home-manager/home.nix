{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ../modules/tmux
  ];
  home.username = "dom";
  home.homeDirectory = "/home/dom";
  home.packages = with pkgs; [
    pinentry
    gnupg
    git
    firefox
    neovim
    google-chrome
  ];
  
  home.stateVersion = "22.11";
}
