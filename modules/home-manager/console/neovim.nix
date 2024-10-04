{ pkgs, lib, config, ... }:

with lib;

{
  config = {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim;
      viAlias = true;
      vimAlias = true;
      extraPackages = with pkgs; [
        ripgrep
        fd
        fzf
        tree-sitter
        nil
        gcc
        rustc
        cargo
        rust-analyzer
        nodejs
        nodePackages.typescript
        terraform-lsp
        lua-language-server
        nodePackages.vim-language-server
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.pyright
        prettierd
        eslint_d
        stylua
      ];
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
    };
  };
}
