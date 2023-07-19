local M = {}

M.config_paths = { './.nvim/nvim-dap.lua' }

M.setup = function()
  if not pcall(require, "dap") then
    vim.notify("[dom.plugins.debugger] Could not find nvim-dap, make sure you load it before nvim-dap-projects.",
      vim.log.levels.ERROR, nil)
    return
  end
  local project_config = ''
  for _, p in ipairs(M.config_paths) do
    local f = io.open(p)
    if f ~= nil then
      f:close()
      project_config = p
      break
    end
  end
  if project_config == '' then
    return
  end
  vim.notify('[dom.plugins.debugger] Found nvim-dap configuration at.' .. project_config, vim.log.levels.INFO, nil)
  require('dap').adapters = (function() return {} end)()
  require('dap').configurations = (function() return {} end)()
  vim.cmd(":luafile " .. project_config)
end

return M
