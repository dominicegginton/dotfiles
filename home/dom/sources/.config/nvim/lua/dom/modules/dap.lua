local has_dap, dap = pcall(require, 'dap')
if not has_dap then return end

local js_ts_languages = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

local function js_debug_executable()
  return vim.fn.exepath('js-debug')
end

--- Node binary from the same Nix closure as js-debug (avoid Cursor's node on PATH).
local function node_executable()
  local js_debug = js_debug_executable()
  if js_debug == '' then return vim.fn.exepath('node') end

  local file = io.open(js_debug, 'r')
  if file then
    local first = file:read('l') or ''
    file:close()
    local node = first:match('"(/nix/store/[^"]+/bin/node)"')
    if node and vim.fn.executable(node) == 1 then return node end
  end

  local node = vim.fn.exepath('node')
  if node ~= '' and not node:match('cursor%-agent') then return node end
  return node ~= '' and node or 'node'
end

local function project_root(bufnr)
  bufnr = bufnr or 0
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == '' then return vim.fn.getcwd() end
  return vim.fs.root(file, { '.git', 'package.json', 'pnpm-workspace.yaml', 'tsconfig.json' })
    or vim.fn.fnamemodify(file, ':p:h')
end

local function source_map_options(root)
  return {
    sourceMaps = true,
    resolveSourceMapLocations = {
      root .. '/**',
      '!**/node_modules/**',
    },
  }
end

local js_debug = js_debug_executable()
if js_debug == '' then
  vim.notify('vscode-js-debug (`js-debug`) not on PATH; TypeScript DAP will not work', vim.log.levels.WARN)
else
  dap.adapters['pwa-node'] = {
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = {
      command = js_debug,
      args = { '${port}' },
    },
  }
end

local node = node_executable()

--- Build a launch config with absolute paths (avoids broken ${workspaceFolder} / source lookup).
local function build_launch_config(bufnr)
  bufnr = bufnr or 0
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':p')
  if file == '' then
    vim.notify('Save the buffer before debugging', vim.log.levels.WARN)
    return nil
  end

  local root = project_root(bufnr)
  local ft = vim.bo[bufnr].filetype
  local is_ts = ft == 'typescript' or ft == 'typescriptreact' or file:match('%.tsx?$')

  local base = vim.tbl_extend('force', {
    type = 'pwa-node',
    request = 'launch',
    cwd = root,
    console = 'integratedTerminal',
    internalConsoleOptions = 'neverOpen',
    skipFiles = { '<node_internals>/**' },
  }, source_map_options(root))

  if is_ts then
    local tsx = root .. '/node_modules/.bin/tsx'
    if vim.fn.executable(tsx) == 1 then
      return vim.tbl_extend('force', base, {
        name = 'Launch TS (tsx)',
        program = file,
        runtimeExecutable = tsx,
      })
    end

    local local_npx = root .. '/node_modules/.bin/npx'
    local npx = vim.fn.executable(local_npx) == 1 and local_npx or (vim.fn.exepath('npx') ~= '' and vim.fn.exepath('npx') or 'npx')
    return vim.tbl_extend('force', base, {
      name = 'Launch TS (npx tsx)',
      runtimeExecutable = npx,
      runtimeArgs = { '-y', 'tsx', file },
    })
  end

  return vim.tbl_extend('force', base, {
    name = 'Launch file (Node)',
    program = file,
    runtimeExecutable = node,
  })
end

local js_launch_configs = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch TS (ts-node)',
    runtimeExecutable = node,
    runtimeArgs = { '-r', 'ts-node/register/transpile-only' },
    program = '${file}',
    cwd = '${workspaceFolder}',
    sourceMaps = true,
    console = 'integratedTerminal',
    internalConsoleOptions = 'neverOpen',
    skipFiles = { '<node_internals>/**' },
  },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach to process',
    processId = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
  },
}

for _, ft in ipairs(js_ts_languages) do
  dap.configurations[ft] = js_launch_configs
end

local has_dapui, dapui = pcall(require, 'dapui')
if has_dapui then
  dapui.setup()

  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
end

local function pick_launch_config(configs)
  if not configs or #configs == 0 then return nil end
  if #configs == 1 then return configs[1] end

  local names = vim.tbl_map(function(c) return c.name end, configs)
  local choice = vim.fn.inputlist(names)
  if choice <= 0 then return nil end
  return configs[choice]
end

local function debug_start_or_continue()
  if dap.session() then
    dap.continue()
    return
  end

  if vim.tbl_contains(js_ts_languages, vim.bo.filetype) then
    local config = build_launch_config()
    if config then dap.run(config) end
    return
  end

  local configs = dap.configurations[vim.bo.filetype]
  if not configs or #configs == 0 then
    vim.notify('No DAP configuration for filetype: ' .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  dap.run(configs[1])
end

vim.keymap.set('n', '<F5>', debug_start_or_continue, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<leader>dc', function()
  if vim.tbl_contains(js_ts_languages, vim.bo.filetype) then
    local auto = build_launch_config()
    local extra = dap.configurations[vim.bo.filetype] or {}
    local configs = {}
    if auto then table.insert(configs, auto) end
    vim.list_extend(configs, extra)
    local config = pick_launch_config(configs)
    if config then dap.run(config) end
    return
  end
  local configs = dap.configurations[vim.bo.filetype]
  local config = pick_launch_config(configs)
  if config then dap.run(config) end
end, { desc = 'Debug: Choose launch configuration' })
vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set(
  'n',
  '<leader>B',
  function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
  { desc = 'Debug: Set Breakpoint' }
)
if has_dapui then vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = 'Debug: Toggle UI' }) end
