{pkgs, ...}: {
  home.sessionVariables = {
    EDITOR = "nvim";
    SYSTEMD_EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimExtraPlugins; [];
    extraPackages = with pkgs; [
      fzf
      ripgrep
      tree-sitter
      rnix-lsp
      terraform-lsp
      lua-language-server
      nodePackages.vim-language-server
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages."@angular/cli"
      nodePackages.pyright
      nodePackages.prettier
      nodePackages.eslint_d
      rust-analyzer
      stylua
      gcc
      gnumake
      nodejs-slim
      swift
    ];
  };
}