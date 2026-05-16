local lsp = vim.lsp

local capabilities = vim.lsp.protocol.make_client_capabilities()

local function default_on_attach(client, bufnr)
  local navigator_lspclient_mapping = require('navigator.lspclient.mapping')
  navigator_lspclient_mapping.setup({ bufnr = bufnr, client = client })
end

local default_config = { capabilities = capabilities, on_attach = default_on_attach }

local function eslint_on_attach(_, bufnr)
  vim.api.nvim_create_autocmd('BufWritePre', { buffer = bufnr, command = 'EslintFixAll' })
  default_on_attach(_, bufnr)
end



local server_cmds = {
  typos_lsp = { 'typos-lsp' },
  vimls = { 'vim-language-server', '--stdio' },
  bashls = { 'bash-language-server', 'start' },
  yamlls = { 'yaml-language-server', '--stdio' },
  dockerls = { 'docker-langserver', '--stdio' },
  docker_compose_language_service = { 'docker-compose-langserver', '--stdio' },
  ts_ls = { 'typescript-language-server', '--stdio' },
  angularls = { 'ngserver', '--stdio' },
  pyright = { 'pyright-langserver', '--stdio' },
  eslint = { 'vscode-eslint-language-server', '--stdio' },
  rust_analyzer = { 'rust-analyzer' },
  lua_ls = { 'lua-language-server' },
  nixd = { 'nixd' },
}

local function start_lsp(server, opts)
  local config = vim.tbl_extend('force', { name = server, cmd = server_cmds[server] }, opts or {})
  lsp.start(config)
end

local servers = {
  typos_lsp = default_config,
  vimls = default_config,
  bashls = default_config,
  yamlls = default_config,
  dockerls = default_config,
  docker_compose_language_service = default_config,
  ts_ls = default_config,
  angularls = default_config,
  pyright = default_config,
}

for server, opts in pairs(servers) do
  start_lsp(server, opts)
end

start_lsp('eslint', {
  capabilities = capabilities,
  on_attach = eslint_on_attach,
})

start_lsp('rust_analyzer', {
  capabilities = capabilities,
  settings = { ['rust-analyzer'] = { diagnostics = { enable = false } } },
  on_attach = default_on_attach,
})

start_lsp('lua_ls', {
  capabilities = capabilities,
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then return end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

start_lsp('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      hint = { enable = true },
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = true,
        library = {
          vim.env.VIMRUNTIME,
          '~/.local/share/nvim/lazy/solarized.nvim',
        },
      },
    },
  },
})

start_lsp('nixd', {
  capabilities = capabilities,
  cmd = { 'nixd' },
  settings = {
    nixd = {
      nixpkgs = { expr = 'import <nixpkgs> {}' },
      formatting = { command = 'nixpkgs-fmt' },
    },
  },
})
