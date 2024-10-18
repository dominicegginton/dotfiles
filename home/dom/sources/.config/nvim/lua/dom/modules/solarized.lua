local cmd = vim.cmd
local solarized = require('solarized')

vim.o.termguicolors = true
vim.o.background = 'light'
solarized.setup({})
cmd('colorscheme solarized')
