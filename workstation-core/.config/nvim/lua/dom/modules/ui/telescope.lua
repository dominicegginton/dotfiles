local telescope = require('telescope')
local themes = require('telescope.themes')

telescope.setup({
  defaults = vim.tbl_extend('force', {
    border = true,
    sorting_strategy = 'ascending',
  }, themes.get_dropdown()),
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
telescope.load_extension('harpoon')
