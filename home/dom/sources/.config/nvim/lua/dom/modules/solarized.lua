local cmd = vim.cmd
local solarized = require('solarized')

vim.o.termguicolors = true
solarized.setup({
  variant = 'winter',
  transparent = { nvimtree = true, normal = true },
})

vim.o.background = 'light'
cmd('colorscheme solarized')
