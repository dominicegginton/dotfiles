local cmd = vim.cmd
local github_theme = require('github-theme')

github_theme.setup({
  options = {
    hide_end_of_buffer = true,
    hide_nc_statusline = true,
    transparent = false,
    terminal_colors = true,
    dim_inactive = true,
    module_default = true,
    inverse = {
      match_paren = false,
      visual = false,
      search = false,
    },
    darken = {
      floats = true,
      sidebars = {
        enabled = true,
        list = {
          'Telescope',
        },
      },
    },
  },
})

cmd('colorscheme github_light')
