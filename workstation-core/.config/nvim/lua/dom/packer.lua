local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local run_treesitter = function()
  local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
  ts_update()
end

return require('packer').startup(function(use)
  -- Packer & Utils & Helpers
  use('wbthomason/packer.nvim')
  use('nvim-lua/plenary.nvim')
  use('MunifTanjim/nui.nvim')

  -- LSP
  use('williamboman/mason.nvim')
  use('williamboman/mason-lspconfig.nvim')
  use('neovim/nvim-lspconfig')

  -- Completion
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-cmdline')
  use('hrsh7th/nvim-cmp')
  use('L3MON4D3/LuaSnip')
  use('saadparwaiz1/cmp_luasnip')
  use('lukas-reineke/cmp-under-comparator')

  -- Syntax Highlighting
  use({ 'nvim-treesitter/nvim-treesitter', run = run_treesitter })

  -- Telescope
  use({ 'nvim-telescope/telescope.nvim', branch = '0.1.x' })
  use('BurntSushi/ripgrep')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

  -- Colorscheme
  use('projekt0n/github-nvim-theme')

  -- Icons
  use('nvim-tree/nvim-web-devicons')
  use('lewis6991/gitsigns.nvim')

  -- UI
  use('nvim-tree/nvim-tree.lua')
  use('Bekaboo/dropbar.nvim')
  use('echasnovski/mini.tabline')
  use('echasnovski/mini.statusline')
  use('rcarriga/nvim-notify')
  use('neogitorg/neogit')
  use('sindrets/diffview.nvim')
  use('folke/trouble.nvim')
  use('stevearc/aerial.nvim')
  use('weilbith/nvim-code-action-menu')
  use('kevinhwang91/nvim-bqf')
  use('rcarriga/nvim-dap-ui')
  use('Pocco81/true-zen.nvim')
  use('folke/which-key.nvim')
  use({ 'j-hui/fidget.nvim', tag = 'legacy' })
  use('tveskag/nvim-blame-line')

  -- Editor
  use('https://git.sr.ht/~whynothugo/lsp_lines.nvim')
  use('echasnovski/mini.comment')
  use('echasnovski/mini.indentscope')
  use('echasnovski/mini.hipatterns')
  use('echasnovski/mini.trailspace')
  use('echasnovski/mini.move')

  -- Linting & Formatting
  use('jose-elias-alvarez/null-ls.nvim')
  use('MunifTanjim/eslint.nvim')
  use('MunifTanjim/prettier.nvim')

  -- Navigation
  use('ThePrimeagen/harpoon')
  use('rmagatti/goto-preview')

  -- Testing
  use('mattkubej/jest.nvim')

  -- Debugging
  use('mfussenegger/nvim-dap')

  -- Extra
  use('github/copilot.vim')
  use('jghauser/mkdir.nvim')
  use('christoomey/vim-tmux-navigator')

  if packer_bootstrap then require('packer').sync() end
end)
