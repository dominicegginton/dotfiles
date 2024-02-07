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

local H = {}

require('packer').startup(function(use)
  -- Packer & Utils & Helpers
  use('wbthomason/packer.nvim')                  -- Plugin Manager
  use('nvim-lua/plenary.nvim')                   -- Lua functions
  use('kevinhwang91/promise-async')              -- Promise-based async functions
  use('echasnovski/mini.misc')                   -- Miscellaneous functions
  use('echasnovski/mini.extra')                  -- Extra 'mini.nvim' functionality
  use({ 'ray-x/guihua.lua', run = H.runguihua }) -- GUI for FZF
  use('muniftanjim/nui.nvim')                    -- UI components
  use('stevearc/dressing.nvim')                  -- UI components

  -- Language Server Protocol and Syntax Highlighting
  use('neovim/nvim-lspconfig')                                       -- LSP configuration
  use({ 'nvim-treesitter/nvim-treesitter', run = H.run_treesitter }) -- Treesitter configurations
  use('filipdutescu/renamer.nvim')                                   -- Rename LSP symbols
  use('aznhe21/actions-preview.nvim')                                -- Preview LSP code actions

  -- GitHub Copilot
  use('github/copilot.vim') -- GitHub Copilot integration

  -- Completion
  use('echasnovski/mini.completion') -- Completion and signature help

  -- Picker
  use('echasnovski/mini.pick') -- Pick anything

  -- Git
  use('neogitorg/neogit')        -- Git interface and tools
  use('sindrets/diffview.nvim')  -- Git diff interface
  use('lewis6991/gitsigns.nvim') -- Git signs
  use('tveskag/nvim-blame-line') -- GitBlame

  -- User Interface
  use('projekt0n/github-nvim-theme')  -- Github theme
  use('nvim-tree/nvim-web-devicons')  -- Icons
  use('echasnovski/mini.starter')     -- Start screen
  use('echasnovski/mini.statusline')  -- Statusline
  use('echasnovski/mini.tabline')     -- Tabline
  use('bekaboo/dropbar.nvim')         -- IDE-like breadcrumbs
  use('nvim-tree/nvim-tree.lua')      -- File explorer
  use('echasnovski/mini.files')       -- Navigate and manipulate file system
  use('echasnovski/mini.notify')      -- Show notifications
  use('j-hui/fidget.nvim')            -- Notifications and LSP progress messages
  use('echasnovski/mini.clue')        -- Show next key clues
  use('folke/trouble.nvim')           -- A pretty diagnostics, references, telescope results, quickfix and location list
  use('echasnovski/mini.cursorword')  -- Autohighlight word under cursor
  use('echasnovski/mini.hipatterns')  -- Highlight patterns in text
  use('echasnovski/mini.indentscope') -- Visualize and work with indent scope

  -- Utilities
  use('jghauser/mkdir.nvim')            -- Create directories when writing a file
  use('christoomey/vim-tmux-navigator') -- Navigate between vim and tmux panes
  use('editorconfig/editorconfig-vim')  -- Editorconfig integration
  use('echasnovski/mini.sessions')      -- Session management
  use('echasnovski/mini.visits')        -- Track and reuse file system visits
  use('echasnovski/mini.fuzzy')         -- Fuzzy matching
  use('kevinhwang91/nvim-ufo')          -- Editor folds
  use('nvim-focus/focus.nvim')          -- Auto-focusing and auto-resizing splits
  use('mhartington/formatter.nvim')     -- File formatting
  use('vuki656/package-info.nvim')      -- Show package.json dependencies information
  use('nullchilly/fsread.nvim')         -- Flow state reading
  use('echasnovski/mini.comment')       -- Comment lines
  use('echasnovski/mini.move')          -- Move any selection in any direction
  use('echasnovski/mini.trailspace')    -- Trailspace (highlight and remove)
  use('echasnovski/mini.jump')          -- Jump to next/previous single character
  use('echasnovski/mini.jump2d')        -- Jump within visible lines
  use('echasnovski/mini.bracketed')     -- Go forward/backward with square brackets
  use('echasnovski/mini.surround')      -- Surround actions

  use('ray-x/navigator.lua')            -- Code analysis & navigation

  if packer_bootstrap then require('packer').sync() end
end)

H.runguihua = 'cd lua/fzy && make'

H.run_treesitter = function()
  local ts_install = require('nvim-treesitter.install')
  local ts_update = ts_install.update({ with_sync = true })
  ts_update()
end

H.run_luasnip = 'make'

H.run_telescope_fzf_native = 'make'
