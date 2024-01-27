local notify = require('notify')

notify.setup({
  stages = 'fade_in_slide_out',
  timeout = 5000,
})

vim.notify = notify
