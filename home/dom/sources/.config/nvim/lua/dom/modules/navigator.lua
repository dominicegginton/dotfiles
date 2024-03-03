local navigator = require('navigator')

navigator.setup({
  border = 'none',
  lsp = {
    disable_lsp = 'all',
    format_on_save = {
      enable = { 'lua' },
    },
  },
})
