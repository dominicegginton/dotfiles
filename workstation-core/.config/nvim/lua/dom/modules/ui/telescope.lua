local telescope = require('telescope')
local themes = require('telescope.themes')

telescope.setup({
  defaults = vim.tbl_extend('force', {
    layout_strategy = 'bottom_pane',
    layout_config = {
      height = 0.4,
    },
    border = true,
    sorting_strategy = 'ascending',
  }, themes.get_ivy({})),
  extentions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
})
telescope.load_extension('fzf')
telescope.load_extension('aerial')
telescope.load_extension('harpoon')
