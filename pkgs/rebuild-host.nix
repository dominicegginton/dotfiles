{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in
  pkgs.writeShellApplication {
    name = "rebuild-host";

    runtimeInputs = with pkgs; [nix];

    text =
      if isDarwin
      then ''
        nix run nix-darwin -- switch --flake "$HOME"/.dotfiles
      ''
      else ''
        sudo nixos-rebuild switch --flake "$HOME"/.dotfiles
      '';
  }
