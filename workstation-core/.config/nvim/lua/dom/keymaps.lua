-- Leader
vim.leader = ' '
vim.g.mapleader = ' '

-- LSP Keymaps
local lsp_on_attach = function(ev)
  local goto_preview = require('goto-preview')
  vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'Hover' })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Goto Declaration' })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Goto Definition' })
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = 'Goto Implementation' })
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = 'Goto Type Definition' })
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = 'Goto References' })
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = 'Signature Help' })
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename' })
  vim.keymap.set(
    { 'n', 'v' },
    '<leader>ca',
    function() vim.cmd('CodeActionMenu') end,
    { buffer = ev.buf, desc = 'Code Action' }
  )
  vim.keymap.set('n', 'gpd', goto_preview.goto_preview_definition, { buffer = ev.buf, desc = 'Preview Definition' })
  vim.keymap.set('n', 'gpr', goto_preview.goto_preview_references, { buffer = ev.buf, desc = 'Preview References' })
  vim.keymap.set(
    'n',
    'gpi',
    goto_preview.goto_preview_implementation,
    { buffer = ev.buf, desc = 'Preview Implementation' }
  )
  vim.keymap.set(
    'n',
    'gpt',
    goto_preview.goto_preview_type_definition,
    { buffer = ev.buf, desc = 'Preview Type Definition' }
  )

  vim.keymap.set(
    'n',
    '<leader>wa',
    vim.lsp.buf.add_workspace_folder,
    { buffer = ev.buf, desc = 'Add Workspace Folder' }
  )
  vim.keymap.set(
    'n',
    '<leader>wr',
    vim.lsp.buf.remove_workspace_folder,
    { buffer = ev.buf, desc = 'Remove Workspace Folder' }
  )
  vim.keymap.set(
    'n',
    '<leader>wl',
    function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    { buffer = ev.buf, desc = 'List Workspace Folders' }
  )
end
vim.keymap.set('n', 'e', vim.diagnostic.open_float, { desc = 'Open Diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Set Location List' })
vim.api.nvim_create_autocmd(
  'LspAttach',
  { group = vim.api.nvim_create_augroup('UserLspConfig', {}), callback = lsp_on_attach }
)

-- Telescope Keymaps
local builtin = require('telescope.builtin')
local notify = require('telescope').extensions.notify
local harpoon = require('telescope').extensions.harpoon

vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Find In Buffer' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find File' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find In Files' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help Tag' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find Old File' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Find Command' })
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Find Document Symbol' })
vim.keymap.set('n', '<leader>fw', builtin.lsp_workspace_symbols, { desc = 'Find Workspace Symbol' })
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Find Reference' })
vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = 'Find Definitions' })
vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Find Implementation' })
vim.keymap.set('n', '<leader>ft', builtin.lsp_type_definitions, { desc = 'Find Type Definition' })
vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Find Quickfix' })
vim.keymap.set('n', '<leader>fy', builtin.registers, { desc = 'Find Register' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymap' })
vim.keymap.set('n', '<leader>fm', harpoon.marks, { desc = 'Find Marked File' })
vim.keymap.set('n', '<leader>fn', notify.notify, { desc = 'Find Notification' })

-- UI Keymaps
local dapui = require('dapui')
local focus = require('true-zen.focus')
local quickfix_list = require('dom.plugins.quickfix-list')
local harpoon_mark = require('harpoon.mark')

vim.keymap.set('n', '<leader>te', function() vim.cmd('NvimTreeToggle') end, { desc = 'Toggle File Explorer' })
vim.keymap.set('n', '<leader>tg', function() vim.cmd('Neogit') end, { desc = 'Toggle Neogit' })
vim.keymap.set('n', '<leader>to', function() vim.cmd('AerialToggle!') end, { desc = 'Toggle Code Outline' })
vim.keymap.set('n', '<leader>td', function() vim.cmd('TroubleToggle') end, { desc = 'Toggle Diagnostics' })
vim.keymap.set('n', '<leader>tr', dapui.toggle, { desc = 'Toggle Debugger' })
vim.keymap.set('n', '<leader>tq', quickfix_list.toggle, { desc = 'Toggle Quickfix' })
vim.keymap.set('n', '<leader>tb', function() vim.cmd('ToggleBlameLine') end, { desc = 'Toggle Git Blame' })
vim.keymap.set('n', '<C-w>o', focus.toggle, { desc = 'Toggle Focus' })

-- Naviagation Keymaps
local preview = require('goto-preview')

vim.keymap.set('n', '<leader>m', harpoon_mark.add_file, { desc = 'Mark File' })
vim.keymap.set('n', '<leader>P', preview.close_all_win, { desc = 'Close All Preview Windows' })
