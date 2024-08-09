local cmd = vim.cmd
local github_theme = require('github-theme')

github_theme.setup({
  options = {
    hide_end_of_buffer = true,
    hide_nc_statusline = true,
    transparent = true,
    dim_inactive = true,
    darken = {
      floats = true,
      sidebars = {
        enable = true,
      },
    },
  },
})

cmd('colorscheme github_light_default')
