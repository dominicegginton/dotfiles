{ lib, pkgs, ... }:

{
  config = {
    home.file = {
      ".aws/config".source = ./sources/.aws/config;
      ".face".source = ./face.jpg;
      ".config".source = ./sources/.config;
      ".config".recursive = true;
      ".arup.gitconfig".source = ./sources/.arup.gitconfig;
      ".editorconfig".source = ./sources/.editorconfig;
      ".gitconfig".source = ./sources/.gitconfig;
      ".gitignore".source = ./sources/.gitignore;
      ".gitmessage".source = ./sources/.gitmessage;
      ".ideavimrc".source = ./sources/.ideavimrc;
    };

    home.packages = with pkgs.unstable; lib.mkIf pkgs.stdenv.isLinux [
      teams-for-linux
      # chromium
      # vscode-with-extensions
      jetbrains.datagrip
      jetbrains.pycharm-professional
      python3
      jetbrains.webstorm
      nodejs
    ];
  };
}
