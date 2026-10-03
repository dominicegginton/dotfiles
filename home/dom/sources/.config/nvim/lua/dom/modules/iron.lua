local iron = require('iron.core')
local view = require('iron.view')
local common = require('iron.fts.common')

local function node_executable()
  local js_debug = vim.fn.exepath('js-debug')
  if js_debug ~= '' then
    local file = io.open(js_debug, 'r')
    if file then
      local first = file:read('l') or ''
      file:close()
      local node = first:match('"(/nix/store/[^"]+/bin/node)"')
      if node and vim.fn.executable(node) == 1 then return node end
    end
  end

  local node = vim.fn.exepath('node')
  if node ~= '' and not node:match('cursor%-agent') then return node end
  return node ~= '' and node or 'node'
end

local function repl_cwd(meta)
  local bufnr = meta.current_bufnr or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == '' then return vim.fn.getcwd() end
  return vim.fs.root(file, { '.git', 'package.json', 'pnpm-workspace.yaml', 'tsconfig.json' })
    or vim.fn.fnamemodify(file, ':p:h')
end

local function shell_quote_argv(argv)
  return table.concat(vim.tbl_map(vim.fn.shellescape, argv), ' ')
end

--- argv for tsx/node (no shell); REPL cwd is set separately.
local function js_runner_argv(meta)
  local bufnr = meta.current_bufnr or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local ft = vim.bo[bufnr].filetype
  local root = repl_cwd(meta)
  local is_ts = ft == 'typescript'
    or ft == 'typescriptreact'
    or (file ~= '' and file:match('%.tsx?$') ~= nil)

  if is_ts then
    local tsx = root .. '/node_modules/.bin/tsx'
    if vim.fn.executable(tsx) == 1 then return { tsx } end

    local npx = root .. '/node_modules/.bin/npx'
    if vim.fn.executable(npx) == 1 then return { npx, '-y', 'tsx' } end

    local ts_node = vim.fn.exepath('ts-node')
    if ts_node ~= '' then return { ts_node } end
  end

  return { node_executable() }
end

--- Start REPL in project root so relative imports (e.g. `import * as S from "./x"`) resolve.
local function js_repl_command(meta)
  local root = repl_cwd(meta)
  local argv = js_runner_argv(meta)
  local inner = string.format('cd %s && exec %s', vim.fn.shellescape(root), shell_quote_argv(argv))
  return { 'bash', '-lc', inner }
end

--- Node-style REPL (tsx / node): multiline via `.editor` in the repl.
local js_repl = {
  command = js_repl_command,
  open = '.editor\n',
  close = '\04',
  block_dividers = { '// %%', '//%%' },
}

iron.setup({
  config = {
    scratch_repl = true,
    dap_integration = true,
    repl_open_cmd = view.bottom(40),
    repl_definition = {
      typescript = js_repl,
      typescriptreact = js_repl,
      javascript = js_repl,
      javascriptreact = js_repl,
      python = {
        command = { 'python3' },
        format = common.bracketed_paste_python,
        block_dividers = { '# %%', '#%%' },
        env = { PYTHON_BASIC_REPL = '1' },
      },
      lua = {
        command = { 'lua' },
      },
      nix = {
        command = { 'nix', 'repl' },
      },
    },
    repl_filetype = function(_, ft)
      return ft
    end,
  },
  keymaps = {
    toggle_repl = '<leader>rt',
    restart_repl = '<leader>rR',
    send_line = '<leader>rl',
    visual_send = '<leader>rv',
    send_paragraph = '<leader>rp',
    send_file = '<leader>rf',
    send_code_block = '<leader>rb',
    send_code_block_and_move = '<leader>rn',
    send_until_cursor = '<leader>ru',
    interrupt = '<leader>rx',
    exit = '<leader>rq',
    clear = '<leader>rc',
  },
  highlight = {
    italic = true,
  },
  ignore_blank_lines = true,
})

vim.keymap.set('n', '<leader>rF', '<cmd>IronFocus<cr>', { desc = 'Repl: Focus window' })
vim.keymap.set('n', '<leader>rh', '<cmd>IronHide<cr>', { desc = 'Repl: Hide window' })
