local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  extentions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
    },
  }
})

telescope.load_extension('fzf')
telescope.load_extension('file_browser')

