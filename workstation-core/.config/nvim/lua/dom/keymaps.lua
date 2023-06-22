vim.leader = ' '

vim.api.nvim_set_keymap(
  'n',
  '<leader>e',
  ':NvimTreeToggle<CR>',
  { noremap = true }
)

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.api.nvim_set_keymap(
  'n',
  '<leader>f/',
  ':Telescope file_browser',
  { noremap = true }
)

local wk = require('which-key')

wk.register(
  {
    e = 'Toggle File Tree',
    f = {
      name = 'Find',
      f = { builtin.find_files, 'Find Files' },
      g = { builtin.live_grep, 'Live Grep' },
      b = { builtin.buffers, 'Buffers' },
      h = { builtin.help_tags, 'Help Tags' },
    },
  },
  { prefix = '<leader>' }
)


vim.o.termguicolors = true
vim.cmd('colorscheme github_light')

