local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'

  -- Completion
  use 'echasnovski/mini.completion'

  -- Syntax Highlighting
   use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  -- Fuzzy Finder
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    requires = {
      'nvim-lua/plenary.nvim',
      'BurntSushi/ripgrep',
      'sharkdp/fd',
    }
  }
  
  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make'
  }

  -- Fuzzy Finder File Browser
  use {
    'nvim-telescope/telescope-file-browser.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    }
  }

  -- UI
  use 'projekt0n/github-nvim-theme'
  use 'nvim-tree/nvim-web-devicons'
  use 'nvim-tree/nvim-tree.lua'
  use 'glepnir/dashboard-nvim'
  use 'echasnovski/mini.tabline'
  use 'echasnovski/mini.statusline'
  use 'echasnovski/mini.indentscope'
  use 'folke/which-key.nvim'
  
  -- Git
  use { 'neogitorg/neogit', requires = 'nvim-lua/plenary.nvim' }
  use 'lewis6991/gitsigns.nvim'

  -- Misc
  use 'github/copilot.vim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
