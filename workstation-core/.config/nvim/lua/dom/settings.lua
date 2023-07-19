-- Settings
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.timeoutlen = 250
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.autoread = true
vim.opt.numberwidth = 3
vim.opt.showcmd = true
vim.opt.cmdheight = 0
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- LSP & Completion Settings
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local lspconfig = require('lspconfig')
local cmp = require('cmp')
local cmp_under_comparator = require('cmp-under-comparator')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

cmp.setup({
  snippit = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources(
    {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
      { name = 'cmdline' },
    },
    {
      { name = 'buffer' },
    }
  ),
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp_under_comparator.under,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  }
})
mason.setup()
mason_lspconfig.setup()
lspconfig['tsserver'].setup({ capabilities = capabilities })
lspconfig['angularls'].setup({ capabilities = capabilities })
lspconfig['pyright'].setup({ capabilities = capabilities })
lspconfig['lua_ls'].setup({ capabilities = capabilities })
vim.diagnostic.config({ virtual_text = false })

-- Linting & Formatting Settings
local null_ls = require('null-ls')
local prettier = require('prettier')

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre"
local async = event == "BufWritePost"
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.completion.spell,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })

      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, async = async })
        end,
        desc = "[lsp] format on save",
      })
    end

    if client.supports_method("textDocument/rangeFormatting") then
      vim.keymap.set("x", "<leader>f", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })
    end
  end,
})
prettier.setup()

-- Debugging Settings
local dap = require('dap')
local vscode = require('dap.ext.vscode')
local debugger = require('dom.plugins.debugger')

vscode.load_launchjs(nil, {})
debugger.setup()

-- Syntax Highlighting Settings
local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
  ensure_installed = {
    'vim',
    'lua',
    'bash',
    'json',
    'yaml',
    'toml',
    'dockerfile',
    'html',
    'css',
    'javascript',
    'typescript',
    'rust',
    'python',
  },
  auto_install = true,
  highlight = {
    enable = true,
  }
})

-- Telescope Settings
local telescope = require('telescope')

telescope.setup({
  file_browser = {
    hidden = true,
  },
  extentions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
    },
  }
})
telescope.load_extension('fzf')
telescope.load_extension('aerial')
telescope.load_extension('file_browser')
telescope.load_extension('gh')
telescope.load_extension('neoclip')

-- Theme
local github_theme = require('github-theme')

github_theme.setup()
vim.cmd('colorscheme github_light')

-- UI Settings
local nvim_tree = require('nvim-tree')
local dropbar = require("dropbar")
local tabline = require('mini.tabline')
local statusline = require('mini.statusline')
local indentscope = require('mini.indentscope')
local notify = require('notify')
local fidget = require('fidget')
local neogit = require('neogit')
local gitsigns = require('gitsigns')
local lsp_lines = require('lsp_lines')
local aerial = require('aerial')
local dap = require('dap')
local dapui = require('dapui')

local HEIGHT_RATIO = 1
local WIDTH_RATIO = 0.25
nvim_tree.setup({
  sort_by = 'case_sensitive',
  view = {
    side = 'right',
    float = {
      enable = false,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
        return {
          relative = 'editor',
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
      end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
    end,
  },
  renderer = {
    highlight_opened_files = 'all',
    highlight_modified = 'all',
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  filters = {
    dotfiles = false,
  },
})
dropbar.setup()
tabline.setup()
statusline.setup()
neogit.setup({
  preview_buffer = {
    kind = "split",
  },
  popup = {
    kind = "split",
  },
  intergrations = {
    diffview = true,
  },
})
indentscope.setup()
notify.setup({ stages = 'static' })
vim.notify = notify
fidget.setup()
gitsigns.setup()
aerial.setup()
lsp_lines.setup()
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Which Key Settings
local wk = require('which-key')
wk.register(
  { t = 'Toggle', f = 'Find', e = 'Executor' },
  { prefix = '<leader>' }
)

-- Extra Settings
local neoclip = require('neoclip')
local executor = require('executor')
local jest = require('nvim-jest')

neoclip.setup()
executor.setup({})
jest.setup()
