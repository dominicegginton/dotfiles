local focus = require('focus')
local quickfix_list = require('dom.plugins.quickfix-list')
local mini_extra = require('mini.extra')
local mini_files = require('mini.files')
local mini_pick = require('mini.pick')
local mini_diff = require('mini.diff')

-- Leader
vim.leader = ' '
vim.g.mapleader = ' '

-- Picker
vim.keymap.set('n', '<leader>/', mini_pick.builtin.grep, { desc = 'Find In Buffer' })
vim.keymap.set('n', '<leader>fo', mini_pick.builtin.files, { desc = 'Find File' })
vim.keymap.set('n', '<leader>fg', mini_pick.builtin.grep_live, { desc = 'Find In Files (live grep)' })
vim.keymap.set('n', '<leader>fG', mini_pick.builtin.grep, { desc = 'Find In Files (grep)' })
vim.keymap.set('n', '<leader>fb', mini_pick.builtin.buffers, { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>fh', mini_pick.builtin.help, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>fr', mini_pick.builtin.resume, { desc = 'Resume Picker' })

-- User Interface
local toggle_nvim_tree = function() vim.cmd('NvimTreeToggle') end
local toggle_mini_file_explorer = function()
  if not mini_files.close() then mini_files.open(vim.api.nvim_buf_get_name(0)) end
end

local toggle_diff_overview = function() mini_diff.toggle_overview() end

local toggle_diagnostic_pannel = function() vim.cmd('Trouble diagnostics toggle win.position=bottom') end
local toggle_lsp_pannel = function() vim.cmd('Trouble lsp toggle win.position=left') end
local toggle_lsp_lens = function() vim.cmd('LspLensToggle') end
local toggle_git_blame = function() vim.cmd('ToggleBlameLine') end
local toggle_read = function() vim.cmd('FSToggle') end
local open_command_palette = function() vim.cmd('CmdPalette') end

vim.keymap.set('n', '<leader>te', toggle_nvim_tree, { desc = 'Toggle File Explorer Pannel' })
vim.keymap.set('n', '<leader>tE', toggle_mini_file_explorer, { desc = 'Toggle Mini File Explorer' })
vim.keymap.set('n', '<leader>td', toggle_diagnostic_pannel, { desc = 'Toggle Diagnostics Pannel' })
vim.keymap.set('n', '<leader>tL', toggle_lsp_pannel, { desc = 'Toggle LSP Pannel' })
vim.keymap.set('n', '<leader>tD', toggle_diff_overview, { desc = 'Toggle Diff Overview' })
vim.keymap.set('n', '<leader>tq', quickfix_list.toggle, { desc = 'Toggle Quickfix' })
vim.keymap.set('n', '<leader>tb', toggle_git_blame, { desc = 'Toggle Git Blame' })
vim.keymap.set('n', '<leader>tl', toggle_lsp_lens, { desc = 'Toggle LSP Lens' })
vim.keymap.set('n', '<leader>tr', toggle_read, { desc = 'Toggle Reading Mode' })
vim.keymap.set('n', '<leader>tp', open_command_palette, { desc = 'Open Command Palette' })

-- Utilities
local auto_format_group = vim.api.nvim_create_augroup('AutoFormat', {})
local format = function() vim.cmd('Format') end
local format_write_callback = function() vim.cmd('FormatWrite') end
local clear_highlighting = function() vim.cmd('noh') end

vim.keymap.set('n', '<leader><leader>f', format, { desc = 'Format' })
vim.keymap.set('n', '<leader><leader>n', clear_highlighting, { desc = 'Clear Highlight' })
vim.api.nvim_create_autocmd('BufWritePost', { group = auto_format_group, callback = format_write_callback })
