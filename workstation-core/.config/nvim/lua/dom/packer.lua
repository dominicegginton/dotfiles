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
  use('wbthomason/packer.nvim')
  use('nvim-lua/plenary.nvim')
  use('MunifTanjim/nui.nvim')

  -- LSP
  use('williamboman/mason.nvim')
  use('williamboman/mason-lspconfig.nvim')
  use('neovim/nvim-lspconfig')
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-cmdline')
  use('hrsh7th/nvim-cmp')
  use('L3MON4D3/LuaSnip')
  use('saadparwaiz1/cmp_luasnip')
  use('lukas-reineke/cmp-under-comparator')
  use({ 'nvim-treesitter/nvim-treesitter', run = H.run_treesitter })

  -- Dap
  use('mfussenegger/nvim-dap')
  use('mxsdev/nvim-dap-vscode-js')
  use({
    'microsoft/vscode-js-debug',
    opt = true,
    run = H.run_vscode_js_debug,
  })

  -- UI
  use('stevearc/aerial.nvim')
  use('rcarriga/nvim-dap-ui')
  use({ 'j-hui/fidget.nvim', tag = 'legacy' })
  use('nvim-focus/focus.nvim')
  use('projekt0n/github-nvim-theme')
  use('lewis6991/gitsigns.nvim')
  use('rmagatti/goto-preview')
  use('echasnovski/mini.statusline')
  use('echasnovski/mini.tabline')
  use('neogitorg/neogit')
  use('rcarriga/nvim-notify')
  use('nvim-tree/nvim-tree.lua')
  use('nvim-tree/nvim-web-devicons')
  use('nvim-telescope/telescope.nvim')
  use('BurntSushi/ripgrep')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })
  use('folke/which-key.nvim')
  use('sindrets/diffview.nvim')
  use('kevinhwang91/nvim-bqf')
  use('weilbith/nvim-code-action-menu')
  use('folke/trouble.nvim')
  use('Pocco81/true-zen.nvim')

  -- Editor
  use('https://git.sr.ht/~whynothugo/lsp_lines.nvim')
  use('echasnovski/mini.comment')
  use('echasnovski/mini.hipatterns')
  use('echasnovski/mini.indentscope')
  use('echasnovski/mini.move')
  use('echasnovski/mini.trailspace')
  use('tveskag/nvim-blame-line')

  -- Extra
  use('github/copilot.vim')
  use('ThePrimeagen/harpoon')
  use('jghauser/mkdir.nvim')
  use('christoomey/vim-tmux-navigator')
  use('mhartington/formatter.nvim')

  if packer_bootstrap then require('packer').sync() end
end)

H.run_treesitter = function()
  local ts_install = require('nvim-treesitter.install')
  local ts_update = ts_install.update({ with_sync = true })
  ts_update()
end

H.run_vscode_js_debug = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out'
