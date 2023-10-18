local dap = require('dap')
local utils = require('dap.utils')
local vscode = require('dap.ext.vscode')
local dap_python = require('dap-python')
local dap_vscode_js = require('dap-vscode-js')

vscode.load_launchjs(nil, {})
dap_python.setup('~/.virtualenvs/debugpy/bin/python')
dap_vscode_js.setup({
  adapters = {
    'pwa-node',
    'pwa-chrome',
    'pwa-msedge',
    'node-terminal',
    'pwa-extensionHost',
  },
})
for _, language in ipairs({ 'typescript', 'javascript' }) do
  dap.configurations[language] = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = utils.pick_process,
      cwd = '${workspaceFolder}',
    },
  }
end
