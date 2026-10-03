local completion = require('mini.completion')

completion.setup({
  -- Delay before showing completion window
  delay = { completion = 100, signature = 50 },

  -- Configuration of signs
  window = {
    info = { height = 25, width = 80, border = 'rounded' },
    signature = { height = 25, width = 80, border = 'rounded' },
  },

  -- Completion source precedence
  source_func = 'auto',
})

-- Map <CR> to confirm completion
vim.keymap.set('i', '<CR>', [[pumvisible() ? "\<C-y>" : "\<CR>"]], { noremap = true, expr = true })

-- Completion keybindings
vim.keymap.set('i', '<C-n>', [[<C-r>=v:lua.MiniCompletion.goto_next()<CR>]])
vim.keymap.set('i', '<C-p>', [[<C-r>=v:lua.MiniCompletion.goto_prev()<CR>]])
