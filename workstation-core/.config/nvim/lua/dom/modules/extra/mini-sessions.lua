local sessions = require('mini.sessions')

sessions.setup({
  autoread = true,
  autowrite = true,
  directory = '~/.local/share/nvim/sessions',
})
