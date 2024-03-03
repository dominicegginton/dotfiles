local notify = require('mini.notify')

notify.setup()

vim.notify = notify.make_notify({
  ERROR = { duration = 5000 },
  WARN = { duration = 3000 },
  INFO = { duration = 2000 },
  DEBUG = { duration = 1000 },
})
