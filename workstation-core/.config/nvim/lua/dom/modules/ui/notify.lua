local notify = require('notify')

notify.setup({ stages = 'static' })
vim.notify = notify
