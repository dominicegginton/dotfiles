local which_key = require('which-key')

which_key.setup({
  window = {
    border = 'single',
  },
})
which_key.register({ t = 'Toggle', f = 'Find', d = 'Debugging' }, { prefix = '<leader>' })
