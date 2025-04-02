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


    # TODO: refactor this
    # work related packeges
    home.packages = with pkgs; lib.mkIf pkgs.stdenv.isLinux [
      unstable.teams-for-linux
      unstable.chromium
      unstable.microsoft-edge
      (unstable.vscode-with-extensions.override
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
