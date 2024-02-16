# Neovim.
#
# Neovim configuration.
{
  pkgs,
  config,
  ...
}: {
  # Session vairbales for neovim.
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.SYSTEMD_EDITOR = "nvim";
  home.sessionVariables.VISUAL = "nvim";

  # Enable neovim.
  programs.neovim = {
    enable = true;

    # Use nightly version of neovim.
    package = pkgs.neovim-nightly;

    # Set alias for vi and vim.
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      nodejs-slim
      gcc
      zig
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
      workspace.nodePackages.custom-elements-languageserver
      prettierd
      eslint_d
      rust-analyzer
      stylua
    ];
  };
}
