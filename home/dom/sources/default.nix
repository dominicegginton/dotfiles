# TODO: move git configs into nix
# TODO: move out of sources
# TODO: move neovim config into its own repo,
#       refactor it to work as a plugin, build
#       it with nix and install it in this flake

{ config, ... }:

{
  home.file = {
    ".face".source = ../face.jpg;
    ".config".source = ../sources/.config;
    ".config".recursive = true;
    ".arup.gitconfig".source = ../sources/.arup.gitconfig;
    ".editorconfig".source = ../sources/.editorconfig;
    ".gitconfig".source = ../sources/.gitconfig;
    ".gitignore".source = ../sources/.gitignore;
    ".gitmessage".source = ../sources/.gitmessage;
  };
}
