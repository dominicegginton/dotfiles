-- Leader
vim.leader = ' '
vim.g.mapleader = ' '

-- LSP Keymaps
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'Open diagnostics' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = 'Set loclist' })
vim.keymap.set('n', '<space>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<space>fS', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })
vim.keymap.set('n', '<space>fr', builtin.lsp_references, { desc = 'References' })
vim.keymap.set('n', '<space>fd', builtin.lsp_definitions, { desc = 'Definitions' })
vim.keymap.set('n', '<space>fi', builtin.lsp_implementations, { desc = 'Implementations' })
vim.keymap.set('n', '<space>ft', builtin.lsp_type_definitions, { desc = 'Type definitions' })
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
  end,
})

-- Fuzzy Finder Keymaps
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find in files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help tags' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find old files' })

-- UI Keymaps
vim.keymap.set('n', '<leader>tt', function() vim.cmd('NvimTreeToggle') end, { desc = 'File Explorer' })
vim.keymap.set('n', '<leader>tg', function() vim.cmd('Neogit') end, { desc = 'Git UI' })
vim.keymap.set('n', '<leader>tc', function() vim.cmd('DiffviewOpen') end, { desc = 'Changes' })
vim.keymap.set('n', '<leader>ta', function() vim.cmd('AerialToggle!') end, { desc = 'Code Outline' })
vim.keymap.set('n', '<leader>td', function() vim.cmd('TroubleToggle') end, { desc = 'Diagnostics' })
