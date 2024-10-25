local cmd = vim.cmd
local solarized = require('solarized')

vim.o.termguicolors = true
vim.o.background = 'light'
solarized.setup({
  variant = 'autumn',
  transparent = { nvimtree = true, normal = true },
})
cmd('colorscheme solarized')
