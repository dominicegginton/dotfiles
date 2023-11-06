local cmd = vim.cmd
local github_theme = require('github-theme')

github_theme.setup({
  options = {
    hide_end_of_buffer = true,
    hide_nc_statusline = true,
    transparent = false,
    dim_inactive = true,
    darken = {
      floats = true,
      sidebars = {
        enabled = true,
      },
    },
  },
})

cmd('colorscheme github_dark_dimmed')
