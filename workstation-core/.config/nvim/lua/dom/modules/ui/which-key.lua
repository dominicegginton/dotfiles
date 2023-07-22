local which_key = require('which-key')

which_key.setup({
  window = {
    border = 'single',
    position = 'bottom',
  },
})
which_key.register({ t = 'Toggle', f = 'Find', d = 'Debugging' }, { prefix = '<leader>' })
