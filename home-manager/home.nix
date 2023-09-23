{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ../modules/tmux
  ];

  home.username = "dom";
  home.homeDirectory = "/home/dom";

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_USE_XINPUT2 = "1";
    XDG_CURRENT_DESKTOP = "sway"; 
  };

  home.packages = with pkgs; [
    pinentry
    gnupg
    git
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
  };

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      tree-sitter
      pkgs.rnix-lsp
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.vim-language-server
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.intelephense
      nodePackages.dockerfile-language-server-nodejs
      rust-analyzer
      stylua
      nodePackages.prettier
    ];
  };

  home.stateVersion = "22.11";
}
