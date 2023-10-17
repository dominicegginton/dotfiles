{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "rebuild-home";

  runtimeInputs = with pkgs; [
    nix
    home-manager
  ];

  text = ''
    home-manager switch -b backup --flake "$HOME"/.dotfiles
  '';
}
