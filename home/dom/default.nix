{ lib, pkgs, ... }:

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

    # TODO: refactor - work related packeges
    home.packages = with pkgs; lib.mkIf pkgs.stdenv.isLinux [
      unstable.teams-for-linux
      unstable.chromium
      unstable.microsoft-edge
      (vscode-with-extensions.override { })
    ];
  };
}
