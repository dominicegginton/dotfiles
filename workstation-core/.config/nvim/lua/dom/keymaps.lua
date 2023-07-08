-- Leader
vim.leader = ' '
vim.g.mapleader = ' '

-- LSP Keymaps
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'Open diagnostics' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = 'Set loclist' })
vim.keymap.set('n', '<spance>T', function() vim.cmd('TroubleToggle') end, { desc = 'Toggle trouble' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Go to declaration' })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Go to definition' })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'Hover' })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = 'Go to implementation' })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = 'Signature help' })
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = 'Add workspace folder' })
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder,
      { buffer = ev.buf, desc = 'Remove workspace folder' })
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { buffer = ev.buf, desc = 'List workspace folders' })
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = 'Go to type definition' })
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename' })
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code action' })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = 'Go to references' })
    vim.keymap.set('n', '<space><space>f', function()
      vim.lsp.buf.format { async = true }
    end, { buffer = ev.buf, desc = 'Format' })
  end,
})

-- Fuzzy Finder Keymaps
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find in files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help tags' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find old files' })

-- Git Keymaps
local neogit = require('neogit')

vim.keymap.set('n', '<leader>gg', neogit.open, { desc = 'NeoGit' })
vim.keymap.set('n', '<leader>gd', function() vim.cmd('DiffviewOpen') end, { desc = 'Diffview' })

-- UI Keymaps
vim.keymap.set('n', '<leader>tt', function() vim.cmd('NvimTreeToggle') end, { desc = 'Toggle NvimTree' })

-- Source NeoVIM Config
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/init.lua<cr>", { desc = 'Source NeoVIM Config' })

-- Which Key Settings
local wk = require('which-key')

wk.register(
  {
    f = 'Find',
    g = 'Git',
  },
  {
    prefix = '<leader>'
  }
)
