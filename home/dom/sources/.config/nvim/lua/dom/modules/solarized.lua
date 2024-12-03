local cmd = vim.cmd
local solarized = require('solarized')
local theme = io.open(os.getenv('HOME') .. '/theme', 'r'):read()

vim.o.termguicolors = true
solarized.setup({
  variant = 'winter',
  transparent = { nvimtree = true, normal = true },
})

if theme == 'light' then
  vim.o.background = 'light'
else
  vim.o.background = 'dark'
end

cmd('colorscheme solarized')
