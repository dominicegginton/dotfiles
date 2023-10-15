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
    my.gpg-keys-utils
    git
    alacritty
    tailscale
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    jetbrains-mono
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
    then [
      my.network-filters-enable
      my.network-filters-disable
    ]
    else []
  );
}
