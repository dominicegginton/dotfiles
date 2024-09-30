local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

local mini_deps = require('mini.deps')
local add = mini_deps.add
mini_deps.setup({ path = { package = path_package } })

-- Utils & Helpers
add('nvim-lua/plenary.nvim') -- Lua functions
add('kevinhwang91/promise-async') -- Promise-based async functions
add('echasnovski/mini.misc') -- Miscellaneous functions
add('echasnovski/mini.extra') -- Extra 'mini.nvim' functionality
add('ray-x/guihua.lua') -- GUI for FZF
add('muniftanjim/nui.nvim') -- UI components
add('stevearc/dressing.nvim') -- UI components
add('ibhagwan/fzf-lua') -- FZF

-- Language Server Protocol and Syntax Highlighting
add('neovim/nvim-lspconfig') -- LSP configuration
add({
  source = 'nvim-treesitter/nvim-treesitter',
  hooks = {
    post_checkout = function() vim.cmd('TSUpdate') end,
  },
}) -- Treesitter configurations
add('ray-x/navigator.lua') -- Code analysis & navigation
add('VidocqH/lsp-lens.nvim') -- Render references and document symbols

-- GitHub Copilot
add('github/copilot.vim') -- GitHub Copilot integration

-- Completion
add('echasnovski/mini.completion') -- Completion and signature help

-- Picker
add('echasnovski/mini.pick') -- Pick anything

-- Git
add('neogitorg/neogit') -- Git interface and tools
add('sindrets/diffview.nvim') -- Git diff interface
add('lewis6991/gitsigns.nvim') -- Git signs
add('tveskag/nvim-blame-line') -- GitBlame

-- User Interface
add('projekt0n/github-nvim-theme') -- Github theme
add('nvim-tree/nvim-web-devicons') -- Icons
add('echasnovski/mini.starter') -- Start screen
add('echasnovski/mini.statusline') -- Statusline
add('echasnovski/mini.tabline') -- Tabline
add('bekaboo/dropbar.nvim') -- IDE-like breadcrumbs
add('nvim-tree/nvim-tree.lua') -- File explorer
add('echasnovski/mini.files') -- Navigate and manipulate file system
add('echasnovski/mini.notify') -- Show notifications
add('j-hui/fidget.nvim') -- Notifications and LSP progress messages
add('echasnovski/mini.clue') -- Show next key clues
add('folke/trouble.nvim') -- A pretty diagnostics, references, telescope results, quickfix and location list
add('echasnovski/mini.cursorword') -- Autohighlight word under cursor
add('echasnovski/mini.hipatterns') -- Highlight patterns in text
add('echasnovski/mini.indentscope') -- Visualize and work with indent scope
add('ellisonleao/glow.nvim') -- Markdown preview

-- Utilities
add('jghauser/mkdir.nvim') -- Create directories when writing a file
add('christoomey/vim-tmux-navigator') -- Navigate between vim and tmux panes
add('editorconfig/editorconfig-vim') -- Editorconfig integration
add('echasnovski/mini.sessions') -- Session management
add('echasnovski/mini.visits') -- Track and reuse file system visits
add('echasnovski/mini.fuzzy') -- Fuzzy matching
add('nvim-focus/focus.nvim') -- Auto-focusing and auto-resizing splits
add('mhartington/formatter.nvim') -- File formatting
add('vuki656/package-info.nvim') -- Show package.json dependencies information
add('nullchilly/fsread.nvim') -- Flow state reading
add('echasnovski/mini.comment') -- Comment lines
add('echasnovski/mini.move') -- Move any selection in any direction
add('echasnovski/mini.trailspace') -- Trailspace (highlight and remove)
add('echasnovski/mini.jump') -- Jump to next/previous single character
add('echasnovski/mini.jump2d') -- Jump within visible lines
add('echasnovski/mini.bracketed') -- Go forward/backward with square brackets
add('echasnovski/mini.surround') -- Surround actions
add('echasnovski/mini.visits') -- Track and reuse file system visits
add('pwntester/octo.nvim') -- GitHub integration
add('AckslD/nvim-neoclip.lua') -- Clipboard manager
