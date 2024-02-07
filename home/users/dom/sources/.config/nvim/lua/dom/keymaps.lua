local focus = require('focus')
local quickfix_list = require('dom.plugins.quickfix-list')
local package_info = require('package-info')
local renamer = require('renamer')

vim.leader = ' '
vim.g.mapleader = ' '

-- Picker
local pick = require('mini.pick')
vim.keymap.set('n', '<leader>/', function() pick.pickers.buf_lines() end, { desc = 'Find In Buffer' })
vim.keymap.set('n', '<leader>fo', function() pick.builtin.files() end, { desc = 'Find File' })
vim.keymap.set('n', '<leader>fg', function() pick.builtin.grep_live() end, { desc = 'Find In Files (live grep)' })
vim.keymap.set('n', '<leader>fG', function() pick.builtin.grep() end, { desc = 'Find In Files (grep)' })
vim.keymap.set('n', '<leader>fh', function() pick.builtin.help() end, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>fr', function() pick.builtin.resume() end, { desc = 'Resume Picker' })
-- TODO - Add a keymap to pick local files for current buffer

-- User Interface
local files = require('mini.files')
vim.keymap.set('n', '<leader>te', function() vim.cmd('NvimTreeToggle') end, { desc = 'Toggle File Explorer' })
vim.keymap.set('n', '<leader>tE', function()
  if not files.close() then files.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = 'Open File Explorer' })
vim.keymap.set('n', '<leader>td', function() vim.cmd('TroubleToggle') end, { desc = 'Toggle Diagnostics' })
vim.keymap.set('n', '<leader>tq', function() quickfix_list.toggle() end, { desc = 'Toggle Quickfix' })
vim.keymap.set('n', '<leader>tb', function() vim.cmd('ToggleBlameLine') end, { desc = 'Toggle Git Blame' })
vim.keymap.set('n', '<leader>tr', function() vim.cmd('FSToggle') end, { desc = 'Toggle Read' })
vim.keymap.set('n', '<leader>tp', function() vim.cmd('CmdPalette') end, { desc = 'Open Command Palette' })
vim.keymap.set('n', '<C-w>o', function() vim.cmd('FocusMaximise') end, { desc = 'Maximise Focus' })
vim.keymap.set('n', '<C-w>=', function() vim.cmd('FocusEqualise') end, { desc = 'Equalize Focus' })

-- Utilities
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
vim.keymap.set('n', '<leader><leader>f', function() vim.cmd('Format') end, { desc = 'Format' })
vim.api.nvim_create_autocmd(
  'BufWritePost',
  { group = vim.api.nvim_create_augroup('UserFormat', {}), callback = function() vim.cmd('FormatWrite') end }
)
