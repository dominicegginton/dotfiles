local telescope = require('telescope')
local themes = require('telescope.themes')
local actions = require('telescope.actions')
local previewers = require('telescope.previewers')
local sorters = require('telescope.sorters')

local width = 0.95
local height = 0.95

telescope.setup({
  defaults = {
    prompt_prefix = '  ',
    selection_caret = ' ',
    entry_prefix = '  ',
    set_env = { ['COLORTERM'] = 'truecolor' },
    initial_mode = 'insert',
    selection_strategy = 'reset',
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    layout_config = {
      prompt_position = 'top',
      horizontal = {
        mirror = false,
        width = width,
        height = height,
      },
      vertical = {
        mirror = false,
        width = width,
        height = height,
      },
    },
    file_sorter = sorters.get_fuzzy_file,
    file_ignore_patterns = { 'node_modules', '.git' },
    generic_sorter = sorters.get_generic_fuzzy_sorter,
    winblend = 0,
    border = true,
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    color_devicons = true,
    use_less = true,
    path_display = {},
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    vimgrep_arguments = {
      'rg',
      '--vimgrep',
      '--hidden',
      '--smart-case',
      '--trim',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
    },
  },
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
