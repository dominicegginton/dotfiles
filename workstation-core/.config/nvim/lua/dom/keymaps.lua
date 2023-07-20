-- Leader
vim.leader = ' '
vim.g.mapleader = ' '

-- LSP Keymaps
vim.keymap.set('n', 'e', vim.diagnostic.open_float, { desc = 'Open Diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Set Location List' })
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Goto Declaration' })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Goto Definition' })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'Hover' })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = 'Goto Implementation' })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = 'Signature Help' })
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder,
      { buffer = ev.buf, desc = 'Add Workspace Folder' })
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
      { buffer = ev.buf, desc = 'Remove Workspace Folder' })
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { buffer = ev.buf, desc = 'List Workspace Folders' })
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = 'Goto Type Definition' })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename' })
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code Action' })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = 'Goto References' })
  end,
})

-- Telescope Keymaps
local builtin = require('telescope.builtin')
local notify = require('telescope').extensions.notify

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find In Files' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Find In Buffer' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help Tags' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find Old Files' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Find Commands' })
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Find Document Symbols' })
vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Find Workspace Symbols' })
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Find References' })
vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = 'Find Definitions' })
vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Find Implementations' })
vim.keymap.set('n', '<leader>ft', builtin.lsp_type_definitions, { desc = 'Find Type Definitions' })
vim.keymap.set('n', '<leader>fn', notify.notify, { desc = 'Find Notifications' })
vim.keymap.set('n', '<leader>fR', function() vim.cmd('Telescope neoclip') end, { desc = 'Find Registers' })

-- UI Keymaps
local dapui = require('dapui')
local quickfix = require('dom.plugins.quickfix')

vim.keymap.set('n', '<leader>tt', function() vim.cmd('NvimTreeToggle') end, { desc = 'Toggle File Explorer' })
vim.keymap.set('n', '<leader>tg', function() vim.cmd('Neogit') end, { desc = 'Toggle Neogit' })
vim.keymap.set('n', '<leader>ta', function() vim.cmd('AerialToggle!') end, { desc = 'Toggle Code Outline' })
vim.keymap.set('n', '<leader>td', function() vim.cmd('TroubleToggle') end, { desc = 'Toggle Diagnostics' })
vim.keymap.set('n', '<leader>tr', dapui.toggle, { desc = 'Toggle Debugger' })
vim.keymap.set('n', '<leader>tq', quickfix.toggle, { desc = 'Toggle Quickfix' })
vim.keymap.set('n', '<leader>tb', function() vim.cmd('ToggleBlameLine') end, { desc = 'Toggle Git Blame' })

-- Extra Keymaps
vim.keymap.set('n', '<leader>er', function() vim.cmd('ExecutorRun') end, { desc = 'Run' })
vim.keymap.set('n', '<leader>ex', function() vim.cmd('ExecutorClear') end, { desc = 'Reset' })
vim.keymap.set('n', '<leader>ev', function() vim.cmd('ExecutorToggleDetail') end, { desc = 'Toggle Detail' })
