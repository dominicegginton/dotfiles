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
  -- Packer
  use 'wbthomason/packer.nvim'

  -- LSP
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'

  -- LSP Completion
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
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make'
  }
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
  use 'Bekaboo/dropbar.nvim'
  use 'echasnovski/mini.tabline'
  use 'echasnovski/mini.statusline'
  use 'echasnovski/mini.indentscope'
  
  -- Git
  use {
    'neogitorg/neogit',
    requires = 'nvim-lua/plenary.nvim'
  }
  use 'sindrets/diffview.nvim'
  use 'lewis6991/gitsigns.nvim'

  -- GitHub Copilot
  use 'github/copilot.vim'

  -- Extra
  use 'folke/which-key.nvim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
