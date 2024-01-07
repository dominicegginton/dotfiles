local M = {}

M.toggle = function()
  local exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win['quickfix'] == 1 then exists = true end
  end
  if exists == true then
    vim.cmd('cclose')
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then vim.cmd('copen') end
end

return M
