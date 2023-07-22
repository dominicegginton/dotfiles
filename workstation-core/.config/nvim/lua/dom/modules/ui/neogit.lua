local neogit = require('neogit')

neogit.setup({
  preview_buffer = {
    kind = 'split',
  },
  popup = {
    kind = 'split',
  },
  intergrations = {
    diffview = true,
  },
})
