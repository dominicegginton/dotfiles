local focus = require('focus')

focus.setup({ autoresize = { enable = false }, ui = { signcolumn = false } })

local ignore_filetypes = { 'neo-tree', 'Trouble' }
local ignore_buftypes = { 'nofile', 'prompt', 'popup' }

local win_enter = function()
  if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then vim.b.focus_disable = true end
end
local file_type = function()
  if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then vim.b.focus_disable = true end
end

local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })
vim.api.nvim_create_autocmd('WinEnter', {
  group = augroup,
  callback = win_enter,
  desc = 'Disable focus autoresize for BufType',
})
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  callback = file_type,
  desc = 'Disable focus autoresize for FileType',
})
