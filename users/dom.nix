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
    gpg-import-keys
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
      network-filters-enable
      network-filters-disable
    ]
    else []
  );
}
