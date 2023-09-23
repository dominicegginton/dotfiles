{ pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
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
  ];
}
