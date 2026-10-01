local lspconfig = require('lspconfig')
local lsp = vim.lsp

-- Setup capabilities with cmp support if available
local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()

if has_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
else
  -- Fallback: add basic capabilities
  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { 'markdown', 'plaintext' },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = { 'documentation', 'detail', 'additionalTextEdits' },
    },
  }
end

-- Global on_attach handler
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  -- LSP keybindings
  vim.keymap.set('n', 'gd', function() lsp.buf.definition() end, opts)
  vim.keymap.set('n', 'gD', function() lsp.buf.declaration() end, opts)
  vim.keymap.set('n', 'gr', function() lsp.buf.references() end, opts)
  vim.keymap.set('n', 'gi', function() lsp.buf.implementation() end, opts)
  vim.keymap.set('n', 'gt', function() lsp.buf.type_definition() end, opts)
  vim.keymap.set('n', 'K', function() lsp.buf.hover() end, opts)
  vim.keymap.set('n', '<leader>rn', function() lsp.buf.rename() end, opts)
  vim.keymap.set('n', '<leader>ca', function() lsp.buf.code_action() end, opts)
  vim.keymap.set('n', '<leader>d', function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist() end, opts)

  -- Format on save for formatters
  if client.supports_method('textDocument/formatting') then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function() lsp.buf.format() end,
    })
  end
end

-- ESLint on_attach with auto-fix
local function eslint_on_attach(client, bufnr)
  on_attach(client, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', '<leader>fe', '<cmd>EslintFixAll<CR>', opts)
  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = bufnr,
    callback = function() vim.cmd('EslintFixAll') end,
  })
end

-- Server configurations
local servers = {
  -- TypeScript/JavaScript
  ts_ls = {
    init_options = {
      preferences = {
        disableSuggestions = false,
        quotePreference = 'single',
      },
    },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = false,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = false,
        },
      },
    },
  },

  -- Bash
  bashls = {},

  -- YAML
  yamlls = {
    settings = {
      yaml = {
        keyOrdering = false,
      },
    },
  },

  -- Docker
  dockerls = {},

  -- Python
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = 'workspace',
          useLibraryCodeForTypes = true,
        },
      },
    },
  },

  -- Vim
  vimls = {},

  -- Nix
  nixd = {
    settings = {
      nixd = {
        nixpkgs = { expr = 'import <nixpkgs> {}' },
        formatting = { command = 'nixpkgs-fmt' },
        diagnostic = { suppress = { 'sema-escaping-antiquotation' } },
      },
    },
  },

  -- Lua
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          return
        end
      end
    end,
    settings = {
      Lua = {
        hint = { enable = true },
        diagnostics = {
          globals = { 'vim' },
          unusedLocalExclude = { '_*' },
        },
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          },
        },
        codeLens = { enable = true },
        completion = { callSnippet = 'Replace', keywordSnippet = 'Disable' },
        telemetry = { enable = false },
      },
    },
  },

  -- Rust
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        assist = { expressionFillDefault = 'match' },
        check = { command = 'clippy' },
        diagnostics = { enable = true },
        imports = { granularity = { group = 'crate' }, prefix = 'self' },
        inlayHints = {
          bindingModeHints = { enable = false },
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
          closureReturnTypeHints = { enable = 'never' },
          discriminantHints = { enable = 'never' },
          expressionAdjustmentHints = { enable = 'never' },
          implicitDrops = { enable = false },
          lifetimeElisionHints = { enable = 'never', useParameterNames = false },
          parameterHints = { enable = true },
          reborrowHints = { enable = 'never' },
          renderColons = true,
          typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
        },
      },
    },
  },

  -- Typos
  typos_lsp = {},

  -- Angular
  angularls = {},
}

-- Setup all servers with lspconfig
for server, config in pairs(servers) do
  local server_config = vim.tbl_deep_extend('force', {
    capabilities = capabilities,
    on_attach = on_attach,
  }, config)

  lspconfig[server].setup(server_config)
end

-- Special setup for ESLint (needs custom on_attach)
lspconfig.eslint.setup({
  capabilities = capabilities,
  on_attach = eslint_on_attach,
})

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = true,
    style = 'minimal',
    border = 'rounded',
    source = 'if_many',
    header = '',
    prefix = '',
  },
})

-- Diagnostic signs
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
