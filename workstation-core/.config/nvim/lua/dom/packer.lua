local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  -- Packer
  use 'wbthomason/packer.nvim'

  -- Plenary
  use 'nvim-lua/plenary.nvim'

  -- LSP
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'

  -- Completion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'lukas-reineke/cmp-under-comparator'

  -- Debugging
  use 'mfussenegger/nvim-dap'

  -- Linting & Formatting
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'MunifTanjim/eslint.nvim'
  use 'MunifTanjim/prettier.nvim'

  -- Syntax Highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    requires = {
      'BurntSushi/ripgrep',
      'sharkdp/fd',
    }
  }
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make'
  }
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'nvim-telescope/telescope-github.nvim'

  -- Theme
  use 'projekt0n/github-nvim-theme'
  use 'nvim-tree/nvim-web-devicons'

  -- UI
  use 'nvim-tree/nvim-tree.lua'
  use 'Bekaboo/dropbar.nvim'
  use 'echasnovski/mini.tabline'
  use 'echasnovski/mini.statusline'
  use 'echasnovski/mini.indentscope'
  use 'rcarriga/nvim-notify'

  use 'neogitorg/neogit'
  use 'sindrets/diffview.nvim'
  use 'rcarriga/nvim-dap-ui'
  use 'folke/trouble.nvim'
  use 'stevearc/aerial.nvim'
  use 'kevinhwang91/nvim-bqf'

  use 'https://git.sr.ht/~whynothugo/lsp_lines.nvim'
  use 'tveskag/nvim-blame-line'
  use 'lewis6991/gitsigns.nvim'
  use {
    'j-hui/fidget.nvim',
    tag = 'legacy',
  }

  -- Which Key
  use 'folke/which-key.nvim'

  -- Extra
  use 'github/copilot.vim'
  use 'jghauser/mkdir.nvim'
  use 'AckslD/nvim-neoclip.lua'
  use 'MunifTanjim/nui.nvim'
  use 'preservim/nerdcommenter'
  use 'mattkubej/jest.nvim'
  use 'google/executor.nvim'
  use 'christoomey/vim-tmux-navigator'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
