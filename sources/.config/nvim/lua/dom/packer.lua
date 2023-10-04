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
  use('kevinhwang91/promise-async')
  use('muniftanjim/nui.nvim')

  -- LSP
  use('neovim/nvim-lspconfig')
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/nvim-cmp')
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-cmdline')
  use('hrsh7th/cmp-calc')
  use('hrsh7th/cmp-copilot')
  use({ 'l3mon4d3/luasnip', run = H.run_luasnip })
  use('saadparwaiz1/cmp_luasnip')
  use('lukas-reineke/cmp-under-comparator')
  use({ 'nvim-treesitter/nvim-treesitter', run = H.run_treesitter })

  -- DAP
  use('mfussenegger/nvim-dap')
  use('mfussenegger/nvim-dap-python')
  use('mxsdev/nvim-dap-vscode-js')
  use({
    'microsoft/vscode-js-debug',
    opt = true,
    run = H.run_vscode_js_debug,
  })

  -- DADBOB
  use('tpope/vim-dadbod')
  use('kristijanhusak/vim-dadbod-ui')
  use('kristijanhusak/vim-dadbod-completion')

  -- UI
  use('stevearc/dressing.nvim')
  use('VonHeikemen/fine-cmdline.nvim')
  use({ 'j-hui/fidget.nvim', tag = 'legacy' })
  use('nvim-focus/focus.nvim')
  use('projekt0n/github-nvim-theme')
  use('lewis6991/gitsigns.nvim')
  use('echasnovski/mini.starter')
  use('echasnovski/mini.statusline')
  use('echasnovski/mini.tabline')
  use('neogitorg/neogit')
  use('rcarriga/nvim-dap-ui')
  use('thehamsta/nvim-dap-virtual-text')
  use('nvim-tree/nvim-tree.lua')
  use('nvim-tree/nvim-web-devicons')
  use('nvim-telescope/telescope.nvim')
  use('burntsushi/ripgrep')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = H.run_telescope_fzf_native })
  use('folke/which-key.nvim')
  use('sindrets/diffview.nvim')
  use('weilbith/nvim-code-action-menu')
  use('folke/trouble.nvim')
  use('bekaboo/dropbar.nvim')
  use('pocco81/true-zen.nvim')

  -- Editor
  use('echasnovski/mini.comment')
  use('echasnovski/mini.cursorword')
  use('echasnovski/mini.hipatterns')
  use('echasnovski/mini.indentscope')
  use('echasnovski/mini.move')
  use('echasnovski/mini.trailspace')
  use('tveskag/nvim-blame-line')
  use('kevinhwang91/nvim-ufo')
  use('filipdutescu/renamer.nvim')
  use('nullchilly/fsread.nvim')

  -- Extra
  use('github/copilot.vim')
  use('theprimeagen/harpoon')
  use('axkirillov/hbac.nvim')
  use('jghauser/mkdir.nvim')
  use('christoomey/vim-tmux-navigator')
  use('mhartington/formatter.nvim')
  use('editorconfig/editorconfig-vim')
  use({
    'iamcco/markdown-preview.nvim',
    run = H.run_markdown_preview,
    setup = H.setup_markdown_preview,
    ft = { 'markdown' },
  })
  use('echasnovski/mini.sessions')
  use('vuki656/package-info.nvim')

  if packer_bootstrap then require('packer').sync() end
end)

H.run_treesitter = function()
  local ts_install = require('nvim-treesitter.install')
  local ts_update = ts_install.update({ with_sync = true })
  ts_update()
end

H.run_luasnip = 'make'

H.run_telescope_fzf_native = 'make'

H.run_markdown_preview = 'cd app && npm install'

H.setup_markdown_preview = function() vim.g.mkdp_filetypes = { 'markdown' } end

H.run_vscode_js_debug = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out'
