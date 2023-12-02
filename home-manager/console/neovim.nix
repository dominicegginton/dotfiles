{pkgs, ...}: {
  home.sessionVariables = {
    EDITOR = "nvim";
    SYSTEMD_EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.nixvim = {
    enable = true;
    package = pkgs.neovim-nightly;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # native dependencies
      fzf
      ripgrep
      tree-sitter
      # compilers and interpreters
      gcc
      gnumake
      nodejs-slim
      rustc
      python3
      swift
      # language servers
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
      workspace.nodePackages.custom-elements-languageserver
      # formatters
      nodePackages.prettier
      # language specific formatters
      nodePackages.eslint_d
      rust-analyzer
      stylua
    ];
  };
}
