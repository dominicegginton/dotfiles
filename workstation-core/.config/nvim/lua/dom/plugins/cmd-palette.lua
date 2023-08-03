local M = {}

local format = function(node)
  if not node or node['label'] == nil then return 'No Label' end
  return node['label']
end

local callback = function(node)
  if not node then return end
  if node['cmd'] then
    vim.cmd(node['cmd'])
  elseif node['callback'] then
    node['callback']()
  else
    print('No cmd nor callback found')
  end
end

M.setup = function(commands)
  M.commands = vim.tbl_deep_extend('force', {}, {}, commands or {})
  vim.cmd("command! -nargs=0 CmdPalette lua require('dom.plugins.cmd-palette').show()")
end

M.show = function()
  vim.ui.select(M.commands, {
    kind = nil,
    format_item = format,
    prompt = 'Command Palette',
  }, callback)
end

return M
