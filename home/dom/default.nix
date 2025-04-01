# TODO: refactor this

{ lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv) isLinux;
in

{
  config = {
    home.file = {
      ".face".source = ./face.jpg;
      ".config".source = ./sources/.config;
      ".config".recursive = true;
      ".arup.gitconfig".source = ./sources/.arup.gitconfig;
      ".editorconfig".source = ./sources/.editorconfig;
      ".gitconfig".source = ./sources/.gitconfig;
      ".gitignore".source = ./sources/.gitignore;
      ".gitmessage".source = ./sources/.gitmessage;
    };

    home.packages = mkIf isLinux [
      pkgs.bitwarden-cli
      pkgs.whatsapp-for-linux
      pkgs.telegram-desktop
      pkgs.thunderbird
      # TODO: refactor this
      # work related packeges
      pkgs.unstable.teams-for-linux
      pkgs.unstable.chromium
      pkgs.unstable.microsoft-edge
      (pkgs.unstable.vscode-with-extensions.override
        {
          vscodeExtensions = with pkgs.unstable.vscode-extensions; [
            bbenoist.nix
            vscodevim.vim
            github.copilot
            github.github-vscode-theme
          ];
        })
    ];
  };
}
