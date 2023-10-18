local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

local capabilities = cmp_nvim_lsp.default_capabilities()
local lsp_defaults = lspconfig.util.default_config
lsp_defaults.capabilities = vim.tbl_extend('force', lsp_defaults.capabilities, capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function eslint_on_attach(_, bufnr)
  vim.api.nvim_create_autocmd('BufWritePre', { buffer = bufnr, command = 'EslintFixAll' })
end

lspconfig['vimls'].setup({ capabilities = capabilities })
lspconfig['bashls'].setup({ capabilities = capabilities })
lspconfig['yamlls'].setup({ capabilities = capabilities })
lspconfig['dockerls'].setup({ capabilities = capabilities })
lspconfig['docker_compose_language_service'].setup({ capabilities = capabilities })
lspconfig['tsserver'].setup({ capabilities = capabilities })
lspconfig['eslint'].setup({ capabilities = capabilities, on_attach = eslint_on_attach })
lspconfig['angularls'].setup({ capabilities = capabilities })
lspconfig['custom_elements_ls'].setup({ capabilities = capabilities })
lspconfig['pyright'].setup({ capabilities = capabilities })
lspconfig['rust_analyzer'].setup({
  capabilities = capabilities,
  ssettings = { ['rust-analyzer'] = { diagnostics = { enable = false } } },
})
lspconfig['lua_ls'].setup({ capabilities = capabilities })
lspconfig['sourcekit'].setup({ capabilities = capabilities })
