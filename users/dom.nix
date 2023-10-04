{ lib, pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
    ../modules/editor.nix
    ../modules/browser.nix
    ../modules/home-manager-applications.nix
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
  ]
    ++
  (
    if pkgs.stdenv.isLinux
    then []
    else []
  )
    ++
  (
    if pkgs.stdenv.isDarwin
    then [ my.network-filters ]
    else []
  );
}
