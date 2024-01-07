local dap = require('dap')
local builtin = require('telescope.builtin')
local utils = require('telescope.utils')
local theme = require('telescope.themes')
local harpoon = require('telescope').extensions.harpoon
local harpoon_mark = require('harpoon.mark')
local focus = require('true-zen.focus')
local quickfix_list = require('dom.plugins.quickfix-list')
local hbac = require('hbac')
local package_info = require('package-info')
local renamer = require('renamer')

vim.leader = ' '
vim.g.mapleader = ' '

-- Lsp Keymaps
vim.keymap.set('n', 'e', vim.diagnostic.open_float, { desc = 'Open Diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Set Location List' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Goto Next Diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Goto Previous Diagnostic' })
vim.keymap.set('n', '<leader>rn', renamer.rename, { desc = 'Rename' })
local lsp_attach = function(ev)
  vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set(
    { 'n', 'v' },
    '<leader>ca',
    function() vim.cmd('CodeActionMenu') end,
    { buffer = ev.buf, desc = 'Code Action' }
  )
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'Hover' })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Goto Declaration' })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Goto Definition' })
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = 'Goto Implementation' })
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = 'Goto Type' })
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = 'Goto References' })
end
local lap_attach_group = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', { group = lap_attach_group, callback = lsp_attach })

-- Dap Kepmaps
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', dap.set_breakpoint, { desc = 'Set Conditional Breakpoint' })
vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Continue' })

-- Telescope Keymaps
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Find In Buffer' })
vim.keymap.set('n', '<leader>fo', builtin.find_files, { desc = 'Find File' })
vim.keymap.set(
  'n',
  '<leader>fl',
  function() builtin.find_files({ cwd = utils.buffer_dir() }) end,
  { desc = 'Find File In Current Directory' }
)
vim.keymap.set('n', '<leader>fh', function() builtin.find_files({ hidden = true }) end, { desc = 'Find File (Hidden)' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find In Files' })
vim.keymap.set('n', '<leader>fb', hbac.telescope, { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>fO', builtin.oldfiles, { desc = 'Find Old File' })
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

-- User Interface Keymaps
-- vim.keymap.set('n', ':', '<cmd>FineCmdline<CR>', { noremap = true })
vim.keymap.set('n', '<leader>te', function() vim.cmd('NvimTreeToggle') end, { desc = 'Toggle File Explorer' })
vim.keymap.set('n', '<leader>to', function() vim.cmd('AerialToggle!') end, { desc = 'Toggle Code Outline' })
vim.keymap.set('n', '<leader>td', function() vim.cmd('TroubleToggle') end, { desc = 'Toggle Diagnostics' })
vim.keymap.set('n', '<leader>tq', function() quickfix_list.toggle() end, { desc = 'Toggle Quickfix' })
vim.keymap.set('n', '<leader>tb', function() vim.cmd('ToggleBlameLine') end, { desc = 'Toggle Git Blame' })
vim.keymap.set('n', '<leader>tr', function() vim.cmd('FSToggle') end, { desc = 'Toggle Read' })
vim.keymap.set('n', '<leader>tp', function() vim.cmd('CmdPalette') end, { desc = 'Open Command Palette' })
vim.keymap.set('n', '<C-w>o', function() focus.toggle() end, { desc = 'Toggle Focus' })
vim.keymap.set('n', '<C-w>=', function() vim.cmd('FocusEqualise') end, { desc = 'Equalize Focus' })
vim.keymap.set('n', '<C-w>Q', function() hbac.close_unpinned() end, { desc = 'Close Unpinned Buffers' })
vim.keymap.set('n', '<leader>p', function() hbac.toggle_pin() end, { desc = 'Toggle Buffer Pin' })
vim.keymap.set('n', '<leader>m', function() harpoon_mark.add_file() end, { desc = 'Mark File' })
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'package.json',
  callback = function()
    vim.keymap.set(
      'n',
      '<leader>tp',
      package_info.toggle,
      { silent = true, noremap = true, desc = 'Toggle Package Info' }
    )
  end,
})

-- Formatting Keymaps
vim.keymap.set('n', '<leader><leader>f', function() vim.cmd('Format') end, { desc = 'Format' })
vim.api.nvim_create_autocmd(
  'BufWritePost',
  { group = vim.api.nvim_create_augroup('UserFormat', {}), callback = function() vim.cmd('FormatWrite') end }
)
