{ pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
    ../modules/editor.nix
    ../modules/browser.nix
    ../modules/home-manager-applications.nix
    ../modules/network-filters.nix
    ../sources
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
}
