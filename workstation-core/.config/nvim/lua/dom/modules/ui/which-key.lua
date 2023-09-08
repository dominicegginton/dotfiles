local which_key = require('which-key')

which_key.setup({
  window = {
    border = 'none',
  },
})
which_key.register({ t = 'Toggle', f = 'Find', d = 'Debugging' }, { prefix = '<leader>' })
