local cmd_palette = require('dom.plugins.cmd-palette')
local hbac = require('hbac')

cmd_palette.setup({
  { label = 'Toggle Current Buffer Pin', callback = hbac.toggle_pin },
})
