{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  home.file = {
    ".config".source = ../sources/.config;
    ".config".recursive = true;
    ".config/alacritty/fonts.yml".source =
      if isDarwin
      then ../sources/.config/alacritty/fonts.darwin.yml
      else ../sources/.config/alacritty/fonts.linux.yml;
    ".arup.gitconfig".source = ../sources/.arup.gitconfig;
    ".editorconfig".source = ../sources/.editorconfig;
    ".gitconfig".source = ../sources/.gitconfig;
    ".gitignore".source = ../sources/.gitignore;
    ".gitmessage".source = ../sources/.gitmessage;
  };
}
