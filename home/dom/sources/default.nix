{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  home.file = {
    ".config".source = ../sources/.config;
    ".config".recursive = true;
    ".arup.gitconfig".source = ../sources/.arup.gitconfig;
    ".editorconfig".source = ../sources/.editorconfig;
    ".gitconfig".source = ../sources/.gitconfig;
    ".gitignore".source = ../sources/.gitignore;
    ".gitmessage".source = ../sources/.gitmessage;
  };
}
