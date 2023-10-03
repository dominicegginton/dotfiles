{ pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
    ../modules/editor.nix
    ../modules/browser.nix
    ../modules/home-manager-applications.nix
    ../modules/network-filters.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    pinentry
    gnupg
    git
    alacritty
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    jetbrains-mono

    nodejs-slim
  ];

  home.file = {
    ".config" = {
      source = ../sources/.config;
      recursive = true;
    };

    ".arup.gitconfig" = {
      source = ../sources/.arup.gitconfig;
    };

    ".editorconfig" = {
      source = ../sources/.editorconfig;
    };

    ".gitconfig" = {
      source  = ../sources/.gitconfig;
    };

    ".gitignore" = {
      source = ../sources/.gitignore;
    };

    ".gitmessage" = {
      source = ../sources/.gitmessage;
    };

    ".npmrc" = {
      source = ../sources/.npmrc;
    };

    "background.jpg" = {
      source = ../sources/background.jpg;
    };

    "dom.jpg" = {
      source = ../sources/dom.jpg;
    };
  };
}
