local lspconfig = require('lspconfig')

local capabilities = lspconfig.util.default_config

local function default_on_attach(client, bufnr)
  local navigator_lspclient_mapping = require('navigator.lspclient.mapping')
  navigator_lspclient_mapping.setup({ bufnr = bufnr, client = client })
end

local default_config = { capabilities = capabilities, on_attach = default_on_attach }

local function eslint_on_attach(_, bufnr)
  vim.api.nvim_create_autocmd('BufWritePre', { buffer = bufnr, command = 'EslintFixAll' })
  default_on_attach(_, bufnr)
end

lspconfig['vimls'].setup(default_config)
lspconfig['bashls'].setup(default_config)
lspconfig['yamlls'].setup(default_config)
lspconfig['dockerls'].setup(default_config)
lspconfig['docker_compose_language_service'].setup(default_config)
lspconfig['tsserver'].setup(default_config)
lspconfig['eslint'].setup({
  capabilities = capabilities,
  on_attach = eslint_on_attach,
})
lspconfig['angularls'].setup(default_config)
lspconfig['pyright'].setup(default_config)
lspconfig['rust_analyzer'].setup({
  capabilities = capabilities,
  ssettings = { ['rust-analyzer'] = { diagnostics = { enable = false } } },
  on_attach = default_on_attach,
})
lspconfig['lua_ls'].setup(default_config)
