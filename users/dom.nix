{ pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
    ../modules/editor.nix
    ../modules/browser.nix
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
      source = ../workstation-core/.config;
      recursive = true;
    };

    ".arup.gitconfig" = {
      source = ../workstation-core/.arup.gitconfig;
    };

    ".editorconfig" = {
      source = ../workstation-core/.editorconfig;
    };

    ".gitconfig" = {
      source  = ../workstation-core/.gitconfig;
    };

    ".gitignore" = {
      source = ../workstation-core/.gitignore;
    };

    ".gitmessage" = {
      source = ../workstation-core/.gitmessage;
    };

    ".npmrc" = {
      source = ../workstation-core/.npmrc;
    };

    "background.jpg" = {
      source = ../workstation-core/background.jpg;
    };

    "dom.jpg" = {
      source = ../workstation-core/dom.jpg;
    };
  };
}
