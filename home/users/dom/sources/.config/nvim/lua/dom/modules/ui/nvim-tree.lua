local nvim_tree = require('nvim-tree')
local nvim_tree_api = require('nvim-tree.api')

-- HEIGHT AND WIDTH
local HEIGHT_RATIO = 1
local WIDTH_RATIO = 0.25
local width = function() return math.floor(vim.opt.columns:get() * WIDTH_RATIO) end

-- OPEN WINDOW CONFIG
local open_win_config = function()
  local screen_w = vim.opt.columns:get()
  local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
  local window_w = screen_w * WIDTH_RATIO
  local window_h = screen_h * HEIGHT_RATIO
  local window_w_int = math.floor(window_w)
  local window_h_int = math.floor(window_h)
  local center_x = (screen_w - window_w) / 2
  local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
  return {
    relative = 'editor',
    row = center_y,
    border = 'none',
    col = center_x,
    width = window_w_int,
    height = window_h_int,
  }
end

-- OPEN NVIM TREE
local open_nvim_tree = function(data)
  local real_file = vim.fn.filereadable(data.file) == 1
  local no_name = data.file == '' and vim.bo[data.buf].buftype == ''
  if not real_file and not no_name then return end
  if vim.fn.expand('%') == '.git/COMMIT_EDITMSG' then return end
  if vim.fn.expand('%') == 'git-rebase-todo' then return end
  nvim_tree_api.tree.toggle({ focus = false, find_file = true })
end
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })

-- NVIM TREE
nvim_tree.setup({
  sort_by = 'case_sensitive',
  update_focused_file = { enable = true },
  view = {
    side = 'right',
    signcolumn = 'no',
    width = width,
    float = {
      enable = false,
      open_win_config = open_win_config,
    },
  },
  renderer = {
    highlight_opened_files = 'all',
    highlight_modified = 'all',
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  filters = {
    dotfiles = false,
    custom = { '^.git$' },
  },
})
